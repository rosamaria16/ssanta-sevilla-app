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


@router.get("/{itinerario_id}", response_model=schemas.ItinerarioDetalleResponse)
def read_itinerario(itinerario_id: int, db: Session = Depends(get_db)):
    db_itinerario = crud.get_itinerario(db, itinerario_id=itinerario_id)
    if db_itinerario is None:
        raise HTTPException(status_code=404, detail="Itinerario no encontrado")
    return db_itinerario


@router.get("/usuario/{usuario_id}", response_model=schemas.ItinerarioDetalleResponse)
def read_itinerario_by_usuario(usuario_id: int, db: Session = Depends(get_db)):
    db_itinerario = crud.get_itinerario_by_usuario(db, usuario_id=usuario_id)
    if db_itinerario is None:
        raise HTTPException(status_code=404, detail="Itinerario no encontrado para este usuario")
    return db_itinerario


@router.post("/", response_model=schemas.ItinerarioResponse, status_code=201)
def create_itinerario(itinerario: schemas.ItinerarioCreate, db: Session = Depends(get_db)):
    existing = crud.get_itinerario_by_usuario(db, usuario_id=itinerario.idUsuario)
    if existing:
        raise HTTPException(status_code=400, detail="El usuario ya tiene un itinerario")
    return crud.create_itinerario(db=db, itinerario=itinerario)


@router.delete("/{itinerario_id}", status_code=204)
def delete_itinerario(itinerario_id: int, db: Session = Depends(get_db)):
    success = crud.delete_itinerario(db, itinerario_id=itinerario_id)
    if not success:
        raise HTTPException(status_code=404, detail="Itinerario no encontrado")
    return None


@router.get("/{itinerario_id}/items", response_model=List[schemas.ItemItinerarioResponse])
def read_items(itinerario_id: int, db: Session = Depends(get_db)):
    db_itinerario = crud.get_itinerario(db, itinerario_id=itinerario_id)
    if db_itinerario is None:
        raise HTTPException(status_code=404, detail="Itinerario no encontrado")
    return crud.get_items_by_itinerario(db, itinerario_id=itinerario_id)


@router.post("/{itinerario_id}/items", response_model=schemas.ItemItinerarioResponse, status_code=201)
def create_item(itinerario_id: int, item: schemas.ItemItinerarioCreate, db: Session = Depends(get_db)):
    db_itinerario = crud.get_itinerario(db, itinerario_id=itinerario_id)
    if db_itinerario is None:
        raise HTTPException(status_code=404, detail="Itinerario no encontrado")
    return crud.create_item_itinerario(db=db, itinerario_id=itinerario_id, item=item)


@router.delete("/{itinerario_id}/items/{item_id}", status_code=204)
def delete_item(itinerario_id: int, item_id: int, db: Session = Depends(get_db)):
    db_item = crud.get_item_itinerario(db, item_id=item_id)
    if db_item is None or db_item.idItinerario != itinerario_id:
        raise HTTPException(status_code=404, detail="Item no encontrado en este itinerario")
    crud.delete_item_itinerario(db, item_id=item_id)
    return None
