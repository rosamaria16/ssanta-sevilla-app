from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Query
from sqlalchemy.orm import Session
from typing import List
from datetime import timedelta
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


@router.get("/dias", response_model=List[schemas.DiaResponse])
def listar_dias(
    usuario_id: int = Query(...),
    db: Session = Depends(get_db),
):
    verificar_admin(db, usuario_id)
    return crud.get_dias(db)


@router.put("/dias/fecha-inicio", response_model=schemas.DiasActualizarFechaInicioResponse)
def actualizar_fechas_desde_inicio(
    datos: schemas.DiasActualizarFechaInicio,
    usuario_id: int = Query(...),
    db: Session = Depends(get_db),
):
    verificar_admin(db, usuario_id)

    dias = crud.get_dias(db)
    if not dias:
        raise HTTPException(status_code=404, detail="No hay días")

    dias_ordenados = sorted(dias, key=lambda d: d.id)

    #Madrugá y Viernes Santo comparten fecha, por eso se repite
    offsets = [0, 1, 2, 3, 4, 5, 6, 7, 7, 8, 9]

    if len(dias_ordenados) != len(offsets):
        offsets = list(range(len(dias_ordenados))) #fallback

    fecha_inicio = datos.fecha_inicio
    for i, dia in enumerate(dias_ordenados):
        nueva_fecha = fecha_inicio + timedelta(days=offsets[i])
        dia_update = schemas.DiaUpdate(fecha=nueva_fecha)
        crud.update_dia(db, dia_id=dia.id, dia=dia_update)

    return schemas.DiasActualizarFechaInicioResponse(
        mensaje=f"Se han actualizado {len(dias_ordenados)} fechas desde {fecha_inicio.strftime('%d/%m/%Y')}",
        dias_actualizados=len(dias_ordenados),
    )

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