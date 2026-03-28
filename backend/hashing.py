import os
from pathlib import Path
from dotenv import load_dotenv
from pwdlib import PasswordHash

import models

load_dotenv(Path(__file__).resolve().parent.parent / ".env")

PASSWORD_HASH = PasswordHash.recommended()
PASSWORD_PEPPER = os.getenv("PASSWORD_PEPPER")
dummy_hash = PASSWORD_HASH.hash(f"dummypassword{PASSWORD_PEPPER}") #dummy hash to prevent timing attacks

#hashing
def verify_password(plain_password, hashed_password):
    return PASSWORD_HASH.verify(f"{plain_password}{PASSWORD_PEPPER}", hashed_password)

def get_password_hash(password):
    return PASSWORD_HASH.hash(f"{password}{PASSWORD_PEPPER}")

def authenticate_user(db, userId: int, password: str):
    user = db.query(models.Usuario).filter(models.Usuario.id == userId).first()
    if not user:
        PASSWORD_HASH.verify(f"{password}{PASSWORD_PEPPER}", dummy_hash)
        return False
    if not verify_password(password, user.contrasena):
        return False
    return user
