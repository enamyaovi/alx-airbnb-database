from rest_framework import serializers
from rest_framework.validators import UniqueValidator
from django.contrib.auth import get_user_model

from email_validator import validate_email, EmailNotValidError
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError

User = get_user_model()


class RegisterUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User 
        fields = [
            "email",
            "password",
            "first_name",
            "last_name",
            "role",
        ]
        extra_kwargs = {
            "password" : {
                "write_only": True,
                "style": {"input_type":"password"}
            },

            "email" : {
                "validators" : [
                    UniqueValidator(
                        queryset=User.objects.all(),
                        message="A user with this email exists!")
                ]
            }
        }
    
    def create(self, validated_data):
        if not validated_data["password"]:
            raise serializers.ValidationError(
                "Password is required")
        if not validated_data['email']:
            raise serializers.ValidationError(
                "Email is required")
        user = User.objects.create_user(**validated_data)
        return user
    
    def update(self, instance, validated_data):
        raise NotImplementedError
    
    def validate_email(self, value):
        try:
            validate_email(value, check_deliverability=True)
        except EmailNotValidError as err:
            raise serializers.ValidationError(f"{str(err)}")
        except Exception as err:
            raise serializers.ValidationError(f"{str(err)}")
        else:
            return value
        
    def validate_password(self, value):
        try:
            validate_password(value)
        except ValidationError as err:
            raise serializers.ValidationError(f"{str(err.messages)}")
        except Exception as err:
            raise serializers.ValidationError(f"{str(err)}")
        return value

class UserDetailSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        date_joined = serializers.DateTimeField(
            source='created_at',
            format= '%Y-%m-%d %H:%M') # type: ignore
        model = User
        fields = [
            'first_name',
            'last_name',
            'email',
            'role',
            'slug',
            'username',
            'date_joined'
        ]
        read_only_fields = [
            'slug',
            'username',
            'email',
            'date_joined'
        ]

    def validate_email(self, validated_data):
        try:
            validate_email(
                validated_data.get('email'),
                check_deliverability=True
            )
        except EmailNotValidError as err:
            raise serializers.ValidationError(f"{str(err)}")
        except Exception as err:
            raise serializers.ValidationError(f"{str(err)}")

    def update(self, instance, validated_data):

        instance.first_name = validated_data.get(
            'first_name', instance.first_name)
        instance.last_name = validated_data.get(
            'last_name',instance.last_name)
        instance.role = validated_data.get(
            'role', instance.role)
        instance.slug = validated_data.get(
            'slug', instance.slug)
        instance.save()
        return instance

class UsersListSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'username',
            'role',
            'email'
        ]
        read_only_fields = ('username', 'role', 'email')

class PasswordChangeSerializer(serializers.Serializer):
    old_password = serializers.CharField(
        required=True, max_length=40)
    new_password = serializers.CharField(
        required=True, max_length=40)
    confirm_password = serializers.CharField(
        required=True, max_length=40)
    
    def validate_old_password(self, attrs):
        o_pswd = attrs.get('old_password')
        user = self.context['request'].user
        if not user.check_password(o_pswd):
            raise serializers.ValidationError(
                'Wrong Password, does not match old')
        
    def validate(self, attrs):
        if attrs.get('new_password') != attrs.get('confirm_password'):
            raise serializers.ValidationError('New passwords do not match')
        try:
            validate_password(attrs.get('new_password'))
        except ValidationError as err:
            raise serializers.ValidationError(f"{err.messages}")
        return attrs
    
    def update(self, instance, validated_data):
        nw_pswd = validated_data['new_password']
        cn_pswd = validated_data['confirm_password']
        if nw_pswd == cn_pswd:
            instance.set_password(cn_pswd)
            instance.save()
        return instance

    def create(self, validated_data):
        raise NotImplementedError
        