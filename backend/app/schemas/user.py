from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr, ConfigDict

class UserRegister(BaseModel):
    name: str
    email: EmailStr
    password: str
    phone: Optional[str] = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserUpdate(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    bio: Optional[str] = None
    avatar_url: Optional[str] = None
    linkedin: Optional[str] = None
    github: Optional[str] = None

class UserPreferencesUpdate(BaseModel):
    language: Optional[str] = None
    theme_mode: Optional[str] = None
    profile_visibility: Optional[bool] = None
    show_online_status: Optional[bool] = None
    allow_message_requests: Optional[bool] = None
    two_factor_auth: Optional[bool] = None

class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str

class UserOut(BaseModel):
    id: int
    name: str
    email: str
    phone: Optional[str] = None
    role: str
    bio: Optional[str] = ""
    avatar_url: Optional[str] = ""
    linkedin: Optional[str] = ""
    github: Optional[str] = ""
    language: Optional[str] = "English"
    theme_mode: Optional[str] = "dark"
    profile_visibility: Optional[bool] = True
    show_online_status: Optional[bool] = True
    allow_message_requests: Optional[bool] = True
    two_factor_auth: Optional[bool] = False
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut
