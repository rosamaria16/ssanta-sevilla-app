from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Query
from sqlalchemy.orm import Session
from typing import List
import crud
import schemas
from database import get_db

router = APIRouter()


def verificar_admin(db: Session, usuario_id: int):
    usuario = crud.get_usuario(db, usuario_id)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    if usuario.admin != 1:
        raise HTTPException(status_code=403, detail="No tienes permisos de administrador")
    return usuario


@router.post("/upload-infopasos", response_model=schemas.CargarInfoPasosResponse)
async def upload_infopasos(
    file: UploadFile = File(...),
    usuario_id: int = Query(...),
    db: Session = Depends(get_db),
):
    verificar_admin(db, usuario_id)

    if not file.filename.endswith(".csv"):
        raise HTTPException(status_code=400, detail="El archivo debe ser un CSV")

    try:
        contenido = await file.read()
        csv_text = contenido.decode("utf-8")
    except UnicodeDecodeError:
        raise HTTPException(status_code=400, detail="El archivo no tiene codificación UTF-8 válida")

    try:
        crud.clear_infopasos(db)
        total = crud.load_infopasos_from_csv(db, csv_text)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    return schemas.CargarInfoPasosResponse(
        mensaje=f"Se cargaron {total} registros correctamente",
        registros_cargados=total,
    )


@router.get("/dias", response_model=List[schemas.DiaResponse])
def listar_dias(
    usuario_id: int = Query(...),
    db: Session = Depends(get_db),
):
    verificar_admin(db, usuario_id)
    return crud.get_dias(db)


@router.put("/dias/{dia_id}/fecha", response_model=schemas.DiaResponse)
def actualizar_fecha_dia(
    dia_id: int,
    datos: schemas.DiaActualizarFecha,
    usuario_id: int = Query(...),
    db: Session = Depends(get_db),
):
    verificar_admin(db, usuario_id)

    dia_update = schemas.DiaUpdate(fecha=datos.fecha)
    db_dia = crud.update_dia(db, dia_id=dia_id, dia=dia_update)
    if db_dia is None:
        raise HTTPException(status_code=404, detail="Día no encontrado")
    return db_dia
