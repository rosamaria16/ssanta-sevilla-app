from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import crud
import schemas
from database import get_db

router = APIRouter()


@router.get("/", response_model=List[schemas.UsuarioResponse])
def read_usuarios(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return crud.get_usuarios(db, skip=skip, limit=limit)


@router.get("/{usuario_id}", response_model=schemas.UsuarioResponse)
def read_usuario(usuario_id: int, db: Session = Depends(get_db)):
    db_usuario = crud.get_usuario(db, usuario_id=usuario_id)
    if db_usuario is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return db_usuario


@router.post("/", response_model=schemas.UsuarioResponse, status_code=201)
def create_usuario(usuario: schemas.UsuarioCreate, db: Session = Depends(get_db)):
    db_usuario = crud.get_usuario_by_email(db, email=usuario.email)
    if db_usuario:
        raise HTTPException(status_code=400, detail="Email ya registrado")
    return crud.create_usuario(db=db, usuario=usuario)


@router.put("/{usuario_id}", response_model=schemas.UsuarioResponse)
def update_usuario(usuario_id: int, usuario: schemas.UsuarioUpdate, db: Session = Depends(get_db)):
    db_usuario = crud.update_usuario(db, usuario_id=usuario_id, usuario=usuario)
    if db_usuario is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return db_usuario

@router.put("/admin/{usuario_id}", response_model=schemas.UsuarioResponse)
def update_admin_usuario(usuario_id: int, usuario: schemas.UsuarioUpdateAdmin, db: Session = Depends(get_db)):
    db_usuario = crud.update_admin_usuario(db, usuario_id=usuario_id, usuario=usuario)
    if db_usuario is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return db_usuario

@router.delete("/{usuario_id}", status_code=204)
def delete_usuario(usuario_id: int, db: Session = Depends(get_db)):
    success = crud.delete_usuario(db, usuario_id=usuario_id)
    if not success:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return None
