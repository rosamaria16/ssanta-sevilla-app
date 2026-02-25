from pydantic import BaseModel, EmailStr
from datetime import datetime, time
from typing import Optional
from enum import Enum

#Enum para el tipo de paso
class TipoPasoEnum(str, Enum):
    CRUZGUIA = "CRUZGUIA"
    PALIO = "PALIO"
    DUELO = "DUELO"
    PASO = "PASO"


#Día
class DiaBase(BaseModel):
    nombre: str
    fecha: datetime

class DiaCreate(DiaBase):
    pass

class DiaUpdate(BaseModel):
    nombre: Optional[str] = None
    fecha: Optional[datetime] = None

class DiaResponse(DiaBase):
    id: int

    class Config:
        from_attributes = True


#Hermandad
class HermandadBase(BaseModel):
    nombre: str
    idDia: int

class HermandadCreate(HermandadBase):
    pass

class HermandadUpdate(BaseModel):
    nombre: Optional[str] = None
    idDia: Optional[int] = None

class HermandadResponse(HermandadBase):
    id: int

    class Config:
        from_attributes = True


#InfoPaso
class InfoPasoBase(BaseModel):
    hora: time
    tipoPaso: TipoPasoEnum
    localizacion: str
    idHermandad: int
    difHora: Optional[time] = None

class InfoPasoCreate(InfoPasoBase):
    pass

class InfoPasoUpdate(BaseModel):
    hora: Optional[time] = None
    tipoPaso: Optional[TipoPasoEnum] = None
    localizacion: Optional[str] = None
    idHermandad: Optional[int] = None
    difHora: Optional[time] = None

class InfoPasoResponse(InfoPasoBase):
    id: int

    class Config:
        from_attributes = True


#Usuario
class UsuarioBase(BaseModel):
    nombre: str
    email: EmailStr

class UsuarioCreate(UsuarioBase):
    contrasena: str

class UsuarioUpdate(BaseModel):
    nombre: Optional[str] = None
    email: Optional[EmailStr] = None
    contrasena: Optional[str] = None

class UsuarioResponse(UsuarioBase):
    id: int

    class Config:
        from_attributes = True


#Itinerario
class ItinerarioBase(BaseModel):
    idUsuario: int
    idInfoPaso: int

class ItinerarioCreate(ItinerarioBase):
    pass

class ItinerarioUpdate(BaseModel):
    idUsuario: Optional[int] = None
    idInfoPaso: Optional[int] = None

class ItinerarioResponse(ItinerarioBase):
    id: int

    class Config:
        from_attributes = True


#Noticia
class NoticiaBase(BaseModel):
    titular: str
    url: str

class NoticiaCreate(NoticiaBase):
    pass

class NoticiaUpdate(BaseModel):
    titular: Optional[str] = None
    url: Optional[str] = None

class NoticiaResponse(NoticiaBase):
    id: int
    fecha: datetime

    class Config:
        from_attributes = True


#Emisora
class EmisoraBase(BaseModel):
    nombre: str
    urlStream: str
    urlImagen: str

class EmisoraCreate(EmisoraBase):
    pass

class EmisoraUpdate(BaseModel):
    nombre: Optional[str] = None
    urlStream: Optional[str] = None
    urlImagen: Optional[str] = None

class EmisoraResponse(EmisoraBase):
    id: int

    class Config:
        from_attributes = True
