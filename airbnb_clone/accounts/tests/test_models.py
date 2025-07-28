from django.test import TestCase
from django.contrib.auth import get_user_model
from faker import Faker, providers
import secrets
from django.core.exceptions import ValidationError

class MyProviders(providers.BaseProvider):
    def password_gen(self):
        return secrets.token_hex(10)

# Create your tests here.
class CustomUserManagerTests(TestCase):
    
    @classmethod
    def setUpTestData(cls) -> None:
        cls.fake = Faker()
        cls.fake.add_provider(MyProviders)
        cls.email = cls.fake.email(safe=True)
        cls.password = cls.fake.password_gen()
        cls.User = get_user_model()

    
    def test_create_user(self):
        user = self.User.objects.create_user(
            email= self.email,
            password = self.password,
            first_name = self.fake.first_name(),
            last_name = self.fake.last_name()
        ) # type: ignore

        self.assertEqual(user.email, self.email)
        self.assertTrue(user.is_active)
        self.assertFalse(user.is_staff)
        self.assertFalse(user.is_superuser)

        with self.assertRaises(
            NotImplementedError,
            msg='Use create_user() or create_superuser() instead of create()'):
            self.User.objects.create()

        with self.assertRaises(
            ValueError,
            msg='Email must be set for Custom User'):
            self.User.objects.create_user(
                email='', 
                password=self.password,
                first_name=self.fake.first_name(),
                last_name=self.fake.last_name())  # type: ignore
            
        with self.assertRaises(TypeError):
            self.User.objects.create_user(
                email=self.email,
                first_name=self.fake.first_name_female(),
                last_name=self.fake.last_name()) #type: ignore

    def test_create_superuser(self):
        s_user = self.User.objects.create_superuser(
            first_name=self.fake.first_name(),
            last_name=self.fake.last_name(),
            email=self.email,
            password=self.password) # type: ignore

        self.assertEqual(s_user.email, self.email)
        self.assertTrue(s_user.is_active)
        self.assertTrue(s_user.is_staff)
        self.assertTrue(s_user.is_superuser)

        with self.assertRaises(
            ValueError,
            msg='Superuser must have is_superuser=True.'):
            self.User.objects.create_superuser(
                email=self.email,
                password=self.password,
                is_superuser=False
            ) # type: ignore

    def test_slug_generation_on_user(self):
        user = self.User.objects.create_user(
            user_id = 'ca68193e-efe3-467c-96cc-4f6c86166fef',
            email=self.email,
            password= self.password,
            first_name= 'John',
            last_name= 'Doe'
        ) #type: ignore

        self.assertEqual(user.slug, "john-doe-66fef")

    def test_get_absolute_url(self):
        pass