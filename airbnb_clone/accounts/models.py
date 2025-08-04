from typing import Any
from django.db import models
from django.contrib.auth.models import (
    AbstractBaseUser, BaseUserManager, PermissionsMixin)

from django.utils.translation import gettext_lazy as _
from django.utils.text import slugify
from django.urls import reverse
import uuid

# Create your models here.
class CustomUserManager(BaseUserManager):
    """
    For managing instances of our Abstract user
    """

    def create(self, **kwargs: Any) -> Any:
        raise NotImplementedError(_(
            "Use create_user() or create_superuser() instead of create()"))

    def create_user(self, email, password, **extra_fields):
        """
        
        """
        if not email:
            raise ValueError(_("Email must be set for Custom User"))
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.full_clean()
        user.save(using=self.db)
        return user
    
    def create_superuser(self, email, password, **extra_fields):
        """
        
        """
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        extra_fields.setdefault('role', CustomUser.URole.ADMIN)

        if extra_fields.get('is_staff') is not True:
            raise ValueError(_('Super User must have is_staff=True.'))
        if extra_fields.get("is_superuser") is not True:
            raise ValueError(_("Superuser must have is_superuser=True."))
        return self.create_user(email, password, **extra_fields)

class CustomUser(AbstractBaseUser, PermissionsMixin):
    """
    
    """
    class URole(models.TextChoices):
        HOST = "HST", _("Host")
        ADMIN = "ADN", _("Administrator")
        GUEST = "GST", _("Guest")

    user_id = models.UUIDField(
        _('User Identification Number'),
        default= uuid.uuid4,
        primary_key=True,
        editable=False,
    )

    first_name = models.CharField(
        _('User First Name'),
        max_length=100,
        null=False,
        # default='John'
    )

    last_name = models.CharField(
        _('Last Name'),
        max_length=150,
        null=False,
        # default='Doe'
    )

    email = models.EmailField(
        _('Email Address'),
        unique=True
    )

    is_staff = models.BooleanField(
        default=False   
    )

    is_superuser = models.BooleanField(
        default=False
    )

    is_active = models.BooleanField(
        default=True
    )

    role = models.CharField(
        _('Role of the user in app'),
        max_length=3,
        choices=URole,
        default=URole.GUEST
    )

    created_at = models.DateTimeField(
        auto_now_add=True
    )

    slug = models.SlugField(
        unique=True,
        blank=True
    )

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name']

    objects = CustomUserManager()

    def generate_slug(self):
        """
        
        """
        fname = self.first_name or "user"
        lname = self.last_name or "anon"
        base_slug = slugify(f"{fname}-{lname}")
        short_uuid = str(self.user_id).replace("-", "")[-5:]
        return f"{base_slug}-{short_uuid}"

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = self.generate_slug()
        super().save(*args, **kwargs)

    def __str__(self) -> str:
        full_name = f"{self.first_name} {self.last_name}"
        return full_name
    
    def get_absolute_url(self):
        return reverse('accounts:user-detail', kwargs={'slug':self.slug})
    
    @property
    def fullname(self):
        full_name = f"{self.first_name} {self.last_name}"
        return full_name.title()

    class Meta:
        verbose_name = "User"
        verbose_name_plural = "Users"
        ordering = ['-created_at']