import csv
from sqlalchemy import text
from database import SessionLocal, engine, Base
from models import Dia, Hermandad, InfoPaso, TipoPaso, Usuario, Emisora, Noticia, Itinerario, ItemItinerario
from datetime import datetime
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_DIR = os.path.join(BASE_DIR, "csv")

def load_dias(db):
    with open(os.path.join(CSV_DIR, "dias.csv"), encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter=";")
        for row in reader:
            dia = Dia(id=int(row['id']), nombre=row['nombre'], fecha=datetime.strptime(row['fecha'], "%Y-%m-%d"))
            db.add(dia)
    print("Loaded días")

         
def load_hermandades(db):
    with open(os.path.join(CSV_DIR, "hermandades.csv"), encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter=";")
        for row in reader:
            hermandad = Hermandad(id=int(row['id']), nombre=row['nombre'], idDia=int(row['idDia']))
            db.add(hermandad)
    print("Loaded hermandades")


def load_infopasos(db):
    with open(os.path.join(CSV_DIR, "infopasos.csv"), encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter=";")
        for row in reader:
            hora_str = row.get('hora', '').strip()
            dif_hora_str = row.get('difHora', '').strip() if row.get('difHora') else ''
            tipo_paso_str = row['tipoPaso'].strip()
            tipo_paso_enum = TipoPaso[tipo_paso_str.upper()]
            
            info_paso = InfoPaso(
                hora=datetime.strptime(hora_str, "%H:%M").time(),
                tipoPaso=tipo_paso_enum,
                localizacion=row['localizacion'],
                idHermandad=int(row['idHermandad']),
                difHora=datetime.strptime(dif_hora_str, "%H:%M").time() if dif_hora_str else None
            )
            db.add(info_paso)
    print("Loaded infopasos")


def load_usuarios(db):
    with open(os.path.join(CSV_DIR, "usuarios.csv"), encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter=";")
        for row in reader:
            usuario = Usuario(
                id=int(row['id']),
                nombre=row['nombre'],
                email=row['email'],
                contrasena=row['contrasena']
            )
            db.add(usuario)
    print("Loaded usuarios")


def load_emisoras(db):
    with open(os.path.join(CSV_DIR, "emisoras.csv"), encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter=";")
        for row in reader:
            emisora = Emisora(
                id=int(row['id']),
                nombre=row['nombre'],
                urlStream=row['urlStream'],
                urlImagen=row['urlImagen']
            )
            db.add(emisora)
    print("Loaded emisoras")


def load_noticias(db):
    with open(os.path.join(CSV_DIR, "noticias.csv"), encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter=";")
        for row in reader:
            noticia = Noticia(
                id=int(row['id']),
                titular=row['titular'],
                url=row['url'],
                fecha=datetime.strptime(row['fecha'], "%Y-%m-%d %H:%M:%S")
            )
            db.add(noticia)
    print("Loaded noticias")


def load_itinerarios(db):
    with open(os.path.join(CSV_DIR, "itinerarios.csv"), encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter=";")
        for row in reader:
            itinerario = Itinerario(
                id=int(row['id']),
                idUsuario=int(row['idUsuario'])
            )
            db.add(itinerario)
    print("Loaded itinerarios")


def load_items_itinerario(db):
    with open(os.path.join(CSV_DIR, "items_itinerario.csv"), encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter=";")
        for row in reader:
            item = ItemItinerario(
                id=int(row['id']),
                idItinerario=int(row['idItinerario']),
                idInfoPaso=int(row['idInfoPaso'])
            )
            db.add(item)
    print("Loaded items_itinerario")


def clear_seed_tables(db):
    db.query(ItemItinerario).delete(synchronize_session=False)
    db.query(Itinerario).delete(synchronize_session=False)
    db.query(InfoPaso).delete(synchronize_session=False)
    db.query(Hermandad).delete(synchronize_session=False)
    db.query(Dia).delete(synchronize_session=False)
    db.query(Noticia).delete(synchronize_session=False)
    db.query(Emisora).delete(synchronize_session=False)
    db.query(Usuario).delete(synchronize_session=False)
    
    
def reset_auto_increment(db):
    db.execute(text("ALTER TABLE items_itinerario AUTO_INCREMENT = 1"))
    db.execute(text("ALTER TABLE itinerarios AUTO_INCREMENT = 1"))
    db.execute(text("ALTER TABLE infopaso AUTO_INCREMENT = 1"))
    db.execute(text("ALTER TABLE hermandades AUTO_INCREMENT = 1"))
    db.execute(text("ALTER TABLE dias AUTO_INCREMENT = 1"))
    db.execute(text("ALTER TABLE noticias AUTO_INCREMENT = 1"))
    db.execute(text("ALTER TABLE emisoras AUTO_INCREMENT = 1"))
    db.execute(text("ALTER TABLE usuarios AUTO_INCREMENT = 1"))
    db.commit()
    print("Reset AUTO_INCREMENT counters")


def create_tables():
    Base.metadata.create_all(bind=engine)
    print("Created tables")
    

def seed_database():
    create_tables()
    db = SessionLocal()
    try:
        clear_seed_tables(db)
        reset_auto_increment(db)
        load_dias(db)
        load_hermandades(db)
        load_infopasos(db)
        load_usuarios(db)
        load_emisoras(db)
        load_noticias(db)
        load_itinerarios(db)
        load_items_itinerario(db)
        db.commit()
    except Exception as e:
        db.rollback()
        print(f"Error: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    seed_database()