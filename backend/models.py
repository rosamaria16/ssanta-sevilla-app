from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Time, Enum
from sqlalchemy.orm import relationship
from datetime import datetime, time
import enum
from database import Base


class TipoPaso(enum.Enum):
    CRUZGUIA = "CruzGuia"
    PALIO = "Palio"


class Usuario(Base):
    __tablename__ = "usuarios"
    
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(50), nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    contrasena = Column(String(255), nullable=False)
    
    itinerario = relationship("Itinerario", back_populates="usuario", uselist=False)


class Itinerario(Base):
    __tablename__ = "itinerarios"
    
    id = Column(Integer, primary_key=True, index=True)
    idUsuario = Column(Integer, ForeignKey("usuarios.id"), nullable=False)
    idInfoPaso = Column(Integer, ForeignKey("infopaso.id"), nullable=False)
    
    usuario = relationship("Usuario", back_populates="itinerario")
    infopaso = relationship("InfoPaso", back_populates="itinerarios")


class Noticia(Base):
    __tablename__ = "noticias"
    
    id = Column(Integer, primary_key=True, index=True)
    titular = Column(String(255), nullable=False)
    url = Column(String(500), nullable=False)
    fecha = Column(DateTime, default=datetime.utcnow, nullable=False)


class Emisora(Base):
    __tablename__ = "emisoras"
    
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), nullable=False)
    urlStream = Column(String(500), nullable=False)
    urlImagen = Column(String(500), nullable=False)

class Dia(Base):
    __tablename__ = "dias"
    
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(50), nullable=False)
    fecha = Column(DateTime, nullable=False)

class Hermandad(Base):
    __tablename__ = "hermandades"
    
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), nullable=False)
    dia = Column(Integer, ForeignKey("dias.id"), nullable=False)
    
    infopaso = relationship("InfoPaso", back_populates="hermandad")


class InfoPaso(Base):
    __tablename__ = "infopaso"
    
    id = Column(Integer, primary_key=True, index=True)
    hora = Column(Time, nullable=False)
    tipoPaso = Column(Enum(TipoPaso), nullable=False)
    localizacion = Column(String(255), nullable=False)
    idHermandad = Column(Integer, ForeignKey("hermandades.id"), nullable=False)
    difHora = Column(Time, nullable=False)
    
    hermandad = relationship("Hermandad", back_populates="infopaso")
    itinerarios = relationship("Itinerario", back_populates="infopaso")
    

