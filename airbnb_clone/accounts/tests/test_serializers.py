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
    
    def setUp(self):
        self.instance = User.objects.create_user(
            email='testboy@gmail.com',
            password='test@12fUz',
            first_name='Test',
            last_name='Nona',
            role='HST'
        ) #type: ignore

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
            instance.slug,
            f"{self.user_data['first_name'].lower()}-{self.user_data['last_name'].lower()}-{str(instance.user_id)[-5:]}")#type: ignore
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
        data['email'] = self.instance.email  # existing email
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
    pass 

class TestUserListSerializer(TestCase):
    pass 

class TestPasswordChangeSerializer(TestCase):
    pass