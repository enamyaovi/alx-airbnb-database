from django.test import TestCase
from django.contrib.auth import get_user_model
from accounts.serializers import (
    RegisterUserSerializer, UserDetailSerializer,
    UsersListSerializer, PasswordChangeSerializer
)
from faker import Faker, providers
import secrets, string, random
from email_validator import EmailNotValidError
from rest_framework import serializers

from unittest.mock import MagicMock

User = get_user_model()

class MyProviders(providers.BaseProvider):
    def password_gen(self):
        characters = string.ascii_letters + string.digits
        return ''.join(secrets.choice(characters) for _ in range(13))
    
    def role_picker(self):
        return random.choice([
            'HST',
            'GST'
        ])


def generate_fake_user():
    fake = Faker()
    fake.add_provider(MyProviders)
    return {
        'email' : fake.email(safe=True, domain='gmail.com'),
        'first_name' : fake.first_name(),
        'last_name' : fake.last_name(),
        'password' : fake.password_gen(),
        'role' : fake.role_picker()
    }
    

class TestRegisterSerializer(TestCase):
    @classmethod
    def setUpTestData(cls) -> None:
        cls.user_data = generate_fake_user()
        cls.test_instance = User.objects.create_user(
            email='testboy@gmail.com',
            password='test@12fUz',
            first_name='Test',
            last_name='Nona',
            role='HST') #type: ignore

    def test_serializer_creation_valid_data(self):
        user_serialized = RegisterUserSerializer(
            data= self.user_data)
        
        self.assertTrue(user_serialized.is_valid())
        self.assertDictContainsSubset(
            user_serialized.validated_data, self.user_data) #type: ignore
        
        instance = user_serialized.save()

        self.assertIsInstance(instance, User)
        self.assertEqual(
            instance.first_name, self.user_data['first_name'])#type: ignore
        self.assertEqual(
            instance.last_name, self.user_data['last_name']) #type: ignore
        self.assertEqual(
            instance.email, self.user_data['email']) #type: ignore
        self.assertEqual(
            instance.role, self.user_data['role']) #type: ignore
        self.assertEqual(
            instance.slug, # type: ignore
            f"{self.user_data['first_name'].lower()}-{self.user_data['last_name'].lower()}-{str(instance.user_id)[-5:]}")  # type: ignore
        self.assertTrue(
            instance.check_password(self.user_data['password']))#type: ignore

    def test_missing_fields(self):
        for field in ['email', 'password', 'first_name', 'last_name', 'role']:
            with self.subTest(field=field):
                data = self.user_data.copy()
                del data[field]
                serializer = RegisterUserSerializer(data=data)
                if field == 'role':
                    self.assertTrue(serializer.is_valid())
                else:
                    self.assertFalse(serializer.is_valid())
                    self.assertIn(field, serializer.errors)

    def test_password_is_write_only(self):
        data = self.user_data.copy()
        serializer = RegisterUserSerializer(data=data)
        serializer.is_valid()
        serialized_data = serializer.data
        self.assertNotIn('password', serialized_data)

    def test_email_normalization(self):
        data = self.user_data.copy()
        data['email'] = '  TestUser@GMAIL.com  '
        serializer = RegisterUserSerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        instance = serializer.save()
        self.assertEqual(instance.email, 'TestUser@gmail.com') #type: ignore

    def test_duplicate_email_registration(self):
        data = self.user_data.copy()
        data['email'] = self.test_instance.email  # existing email
        serializer = RegisterUserSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn('email', serializer.errors)

    def test_invalid_email_format(self):
        data = self.user_data.copy()
        for email in ['invalid-email', 'fakecom@']:
            data['email'] = email
            serializer = RegisterUserSerializer(data=data)
            self.assertFalse(serializer.is_valid())
            self.assertIn('email', serializer.errors)

    def test_invalid_password(self):
        data = self.user_data.copy()
        for pswd in ['common','123456', '123hell']:
            data['password'] = pswd
            serializer = RegisterUserSerializer(data=data)
            self.assertFalse(serializer.is_valid())
            self.assertIn('password', serializer.errors)

class TestUserDetailSerializer(TestCase):
    @classmethod
    def setUpTestData(cls) -> None:
        cls.user1_data = generate_fake_user()
        cls.user2_data = generate_fake_user()

        cls.user1 = User.objects.create_user(
            **cls.user1_data)
        #remove role attribute automatically set for 
        #superuser as ADMIN
        cls.user2_data.pop('role')
        cls.admin_user = User.objects.create_superuser(
            **cls.user2_data)
    
    def setUp(self):
        self.user1.refresh_from_db()
        self.admin_user.refresh_from_db()


    def test_serialization_of_user_detail(self):
        serialized_user = UserDetailSerializer(
            instance=self.user1)
        serialized_admin = UserDetailSerializer(
            instance = self.admin_user)
        
        self.assertIsInstance(serialized_user, UserDetailSerializer)
        self.assertIsInstance(serialized_admin, UserDetailSerializer)

        #testing the fields present
        self.assertDictEqual(
            dict(serialized_user.data),
            {
                'first_name':self.user1_data['first_name'],
                'last_name':self.user1_data['last_name'],
                'email':self.user1_data['email'],
                'role':self.user1_data['role'],
                'slug': self.user1.slug, # type: ignore
                'date_joined':self.user1.created_at.isoformat( # type: ignore
                ).replace("+00:00", "Z")
            }
        )

        self.assertEqual(serialized_admin.data['role'], 'ADN') # type: ignore

    def test_partial_update_method_of_serializer(self):

        #update the users email, last_name, role
        update_data = {
            'email':'testboy123@gmail.com',
            'last_name':'Testy',
            'role':'HST'}

        serialized_user = UserDetailSerializer(
            instance=self.user1, data=update_data, partial=True)
        
        self.assertTrue(serialized_user.is_valid(raise_exception=True))
        serialized_user.save()
        self.assertEqual(update_data['email'], self.user1.email)
        self.assertEqual(update_data['last_name'], self.user1.last_name)
        self.assertEqual(update_data['role'], self.user1.role) # type: ignore

    def test_wrong_email_update(self):
        update_email = {'email':'somewrongemail'}

        serialized_user = UserDetailSerializer(
            instance=self.user1, data=update_email, partial=True)
        
        with self.assertRaises(serializers.ValidationError):
            serialized_user.is_valid(raise_exception=True)
            self.assertIn('Email', serialized_user.errors)


class TestUserListSerializer(TestCase):
    @classmethod
    def setUpTestData(cls) -> None:
        cls.user_data_list = [generate_fake_user() for i in range(1,7)]
        for user_data in cls.user_data_list:
                User.objects.create_user(**user_data)
        cls.queryset = User.objects.all()

    def test_list_serializer(self):
        serialized_users = UsersListSerializer(
            instance=self.queryset,
            many=True
        )

        self.assertEqual(
            [{
                'role':user.role, # type: ignore
                'email':user.email,
                'full_name':user.fullname # type: ignore
            } for user in self.queryset],
            serialized_users.data
        )

class TestPasswordChangeSerializer(TestCase):
    @classmethod
    def setUpTestData(cls) -> None:
        cls.user_data = generate_fake_user()
        cls.user = User.objects.create_user(
            **cls.user_data
        )
        cls.mock_request = MagicMock()
        cls.mock_request.user = cls.user
        cls.password_data = {
            'old_password':cls.user_data['password'],
            'new_password':'myNw12pass#',
            'confirm_password':'myNw12pass#'}

    def setUp(self):
        self.user.refresh_from_db()

    def test_password_change(self):
        
        serialized_passwd = PasswordChangeSerializer(data=self.password_data, context = {'request':self.mock_request})

        self.assertTrue(serialized_passwd.is_valid(raise_exception=True))
        serialized_passwd.save()

        self.user.refresh_from_db()

        self.assertFalse(self.user.check_password(self.user_data['password']))
        self.assertTrue(self.user.check_password('myNw12pass#'))

    def test_wrong_old_password(self):
        data = self.password_data.copy()
        data['old_password'] = 'wrongpassword'
        serialized = PasswordChangeSerializer(
            data=data,
            context = {'request':self.mock_request}
        )

        with self.assertRaises(serializers.ValidationError):
            serialized.is_valid(raise_exception=True)
            self.assertIn('Wrong Password', serialized.errors)

    def test_new_passwords_no_match(self):
        data = self.password_data.copy()
        data['new_password'] = 'no_match'
        data['confirm_password'] = 'no_no_match'

        serialized = PasswordChangeSerializer(
            data=data,
            context = {'request':self.mock_request}
        )

        with self.assertRaises(serializers.ValidationError):
            serialized.is_valid(raise_exception=True)
            self.assertIn('New passwords do not match', serialized.errors)