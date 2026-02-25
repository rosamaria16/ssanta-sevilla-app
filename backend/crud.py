from sqlalchemy.orm import Session
from typing import List, Optional
import models
import schemas


#Día
def get_dia(db: Session, dia_id: int) -> Optional[models.Dia]:
    return db.query(models.Dia).filter(models.Dia.id == dia_id).first()

def get_dias(db: Session, skip: int = 0, limit: int = 100) -> List[models.Dia]:
    return db.query(models.Dia).offset(skip).limit(limit).all()

def create_dia(db: Session, dia: schemas.DiaCreate) -> models.Dia:
    db_dia = models.Dia(**dia.model_dump())
    db.add(db_dia)
    db.commit()
    db.refresh(db_dia)
    return db_dia

def update_dia(db: Session, dia_id: int, dia: schemas.DiaUpdate) -> Optional[models.Dia]:
    db_dia = get_dia(db, dia_id)
    if db_dia:
        update_data = dia.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_dia, key, value)
        db.commit()
        db.refresh(db_dia)
    return db_dia

def delete_dia(db: Session, dia_id: int) -> bool:
    db_dia = get_dia(db, dia_id)
    if db_dia:
        db.delete(db_dia)
        db.commit()
        return True
    return False


#Hermandad
def get_hermandad(db: Session, hermandad_id: int) -> Optional[models.Hermandad]:
    return db.query(models.Hermandad).filter(models.Hermandad.id == hermandad_id).first()

def get_hermandades(db: Session, skip: int = 0, limit: int = 100) -> List[models.Hermandad]:
    return db.query(models.Hermandad).offset(skip).limit(limit).all()

def get_hermandades_by_dia(db: Session, dia_id: int) -> List[models.Hermandad]:
    return db.query(models.Hermandad).filter(models.Hermandad.idDia == dia_id).all()

def create_hermandad(db: Session, hermandad: schemas.HermandadCreate) -> models.Hermandad:
    db_hermandad = models.Hermandad(**hermandad.model_dump())
    db.add(db_hermandad)
    db.commit()
    db.refresh(db_hermandad)
    return db_hermandad

def update_hermandad(db: Session, hermandad_id: int, hermandad: schemas.HermandadUpdate) -> Optional[models.Hermandad]:
    db_hermandad = get_hermandad(db, hermandad_id)
    if db_hermandad:
        update_data = hermandad.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_hermandad, key, value)
        db.commit()
        db.refresh(db_hermandad)
    return db_hermandad

def delete_hermandad(db: Session, hermandad_id: int) -> bool:
    db_hermandad = get_hermandad(db, hermandad_id)
    if db_hermandad:
        db.delete(db_hermandad)
        db.commit()
        return True
    return False


#InfoPaso
def get_infopaso(db: Session, infopaso_id: int) -> Optional[models.InfoPaso]:
    return db.query(models.InfoPaso).filter(models.InfoPaso.id == infopaso_id).first()

def get_infopasos(db: Session, skip: int = 0, limit: int = 100) -> List[models.InfoPaso]:
    return db.query(models.InfoPaso).offset(skip).limit(limit).all()

def get_infopasos_by_hermandad(db: Session, hermandad_id: int) -> List[models.InfoPaso]:
    return db.query(models.InfoPaso).filter(models.InfoPaso.idHermandad == hermandad_id).all()

def create_infopaso(db: Session, infopaso: schemas.InfoPasoCreate) -> models.InfoPaso:
    db_infopaso = models.InfoPaso(**infopaso.model_dump())
    db.add(db_infopaso)
    db.commit()
    db.refresh(db_infopaso)
    return db_infopaso

def update_infopaso(db: Session, infopaso_id: int, infopaso: schemas.InfoPasoUpdate) -> Optional[models.InfoPaso]:
    db_infopaso = get_infopaso(db, infopaso_id)
    if db_infopaso:
        update_data = infopaso.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_infopaso, key, value)
        db.commit()
        db.refresh(db_infopaso)
    return db_infopaso

def delete_infopaso(db: Session, infopaso_id: int) -> bool:
    db_infopaso = get_infopaso(db, infopaso_id)
    if db_infopaso:
        db.delete(db_infopaso)
        db.commit()
        return True
    return False


#Usuario
def get_usuario(db: Session, usuario_id: int) -> Optional[models.Usuario]:
    return db.query(models.Usuario).filter(models.Usuario.id == usuario_id).first()

def get_usuario_by_email(db: Session, email: str) -> Optional[models.Usuario]:
    return db.query(models.Usuario).filter(models.Usuario.email == email).first()

def get_usuarios(db: Session, skip: int = 0, limit: int = 100) -> List[models.Usuario]:
    return db.query(models.Usuario).offset(skip).limit(limit).all()

def create_usuario(db: Session, usuario: schemas.UsuarioCreate) -> models.Usuario:
    db_usuario = models.Usuario(**usuario.model_dump())
    db.add(db_usuario)
    db.commit()
    db.refresh(db_usuario)
    return db_usuario

def update_usuario(db: Session, usuario_id: int, usuario: schemas.UsuarioUpdate) -> Optional[models.Usuario]:
    db_usuario = get_usuario(db, usuario_id)
    if db_usuario:
        update_data = usuario.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_usuario, key, value)
        db.commit()
        db.refresh(db_usuario)
    return db_usuario

def delete_usuario(db: Session, usuario_id: int) -> bool:
    db_usuario = get_usuario(db, usuario_id)
    if db_usuario:
        db.delete(db_usuario)
        db.commit()
        return True
    return False


#Itinerario
def get_itinerario(db: Session, itinerario_id: int) -> Optional[models.Itinerario]:
    return db.query(models.Itinerario).filter(models.Itinerario.id == itinerario_id).first()

def get_itinerarios(db: Session, skip: int = 0, limit: int = 100) -> List[models.Itinerario]:
    return db.query(models.Itinerario).offset(skip).limit(limit).all()

def get_itinerarios_by_usuario(db: Session, usuario_id: int) -> List[models.Itinerario]:
    return db.query(models.Itinerario).filter(models.Itinerario.idUsuario == usuario_id).all()

def create_itinerario(db: Session, itinerario: schemas.ItinerarioCreate) -> models.Itinerario:
    db_itinerario = models.Itinerario(**itinerario.model_dump())
    db.add(db_itinerario)
    db.commit()
    db.refresh(db_itinerario)
    return db_itinerario

def update_itinerario(db: Session, itinerario_id: int, itinerario: schemas.ItinerarioUpdate) -> Optional[models.Itinerario]:
    db_itinerario = get_itinerario(db, itinerario_id)
    if db_itinerario:
        update_data = itinerario.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_itinerario, key, value)
        db.commit()
        db.refresh(db_itinerario)
    return db_itinerario

def delete_itinerario(db: Session, itinerario_id: int) -> bool:
    db_itinerario = get_itinerario(db, itinerario_id)
    if db_itinerario:
        db.delete(db_itinerario)
        db.commit()
        return True
    return False


#Noticia
def get_noticia(db: Session, noticia_id: int) -> Optional[models.Noticia]:
    return db.query(models.Noticia).filter(models.Noticia.id == noticia_id).first()

def get_noticias(db: Session, skip: int = 0, limit: int = 100) -> List[models.Noticia]:
    return db.query(models.Noticia).offset(skip).limit(limit).all()

def create_noticia(db: Session, noticia: schemas.NoticiaCreate) -> models.Noticia:
    db_noticia = models.Noticia(**noticia.model_dump())
    db.add(db_noticia)
    db.commit()
    db.refresh(db_noticia)
    return db_noticia

def update_noticia(db: Session, noticia_id: int, noticia: schemas.NoticiaUpdate) -> Optional[models.Noticia]:
    db_noticia = get_noticia(db, noticia_id)
    if db_noticia:
        update_data = noticia.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_noticia, key, value)
        db.commit()
        db.refresh(db_noticia)
    return db_noticia

def delete_noticia(db: Session, noticia_id: int) -> bool:
    db_noticia = get_noticia(db, noticia_id)
    if db_noticia:
        db.delete(db_noticia)
        db.commit()
        return True
    return False


#Emisora
def get_emisora(db: Session, emisora_id: int) -> Optional[models.Emisora]:
    return db.query(models.Emisora).filter(models.Emisora.id == emisora_id).first()

def get_emisoras(db: Session, skip: int = 0, limit: int = 100) -> List[models.Emisora]:
    return db.query(models.Emisora).offset(skip).limit(limit).all()

def create_emisora(db: Session, emisora: schemas.EmisoraCreate) -> models.Emisora:
    db_emisora = models.Emisora(**emisora.model_dump())
    db.add(db_emisora)
    db.commit()
    db.refresh(db_emisora)
    return db_emisora

def update_emisora(db: Session, emisora_id: int, emisora: schemas.EmisoraUpdate) -> Optional[models.Emisora]:
    db_emisora = get_emisora(db, emisora_id)
    if db_emisora:
        update_data = emisora.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_emisora, key, value)
        db.commit()
        db.refresh(db_emisora)
    return db_emisora

def delete_emisora(db: Session, emisora_id: int) -> bool:
    db_emisora = get_emisora(db, emisora_id)
    if db_emisora:
        db.delete(db_emisora)
        db.commit()
        return True
    return False
