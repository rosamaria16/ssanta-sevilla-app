from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import crud
import schemas
from database import get_db

router = APIRouter()


@router.get("/", response_model=List[schemas.ItinerarioResponse])
def read_itinerarios(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return crud.get_itinerarios(db, skip=skip, limit=limit)


@router.get("/{itinerario_id}", response_model=schemas.ItinerarioResponse)
def read_itinerario(itinerario_id: int, db: Session = Depends(get_db)):
    db_itinerario = crud.get_itinerario(db, itinerario_id=itinerario_id)
    if db_itinerario is None:
        raise HTTPException(status_code=404, detail="Itinerario no encontrado")
    return db_itinerario


@router.get("/usuario/{usuario_id}", response_model=List[schemas.ItinerarioResponse])
def read_itinerarios_by_usuario(usuario_id: int, db: Session = Depends(get_db)):
    return crud.get_itinerarios_by_usuario(db, usuario_id=usuario_id)


@router.post("/", response_model=schemas.ItinerarioResponse, status_code=201)
def create_itinerario(itinerario: schemas.ItinerarioCreate, db: Session = Depends(get_db)):
    return crud.create_itinerario(db=db, itinerario=itinerario)


@router.put("/{itinerario_id}", response_model=schemas.ItinerarioResponse)
def update_itinerario(itinerario_id: int, itinerario: schemas.ItinerarioUpdate, db: Session = Depends(get_db)):
    db_itinerario = crud.update_itinerario(db, itinerario_id=itinerario_id, itinerario=itinerario)
    if db_itinerario is None:
        raise HTTPException(status_code=404, detail="Itinerario no encontrado")
    return db_itinerario


@router.delete("/{itinerario_id}", status_code=204)
def delete_itinerario(itinerario_id: int, db: Session = Depends(get_db)):
    success = crud.delete_itinerario(db, itinerario_id=itinerario_id)
    if not success:
        raise HTTPException(status_code=404, detail="Itinerario no encontrado")
    return None
