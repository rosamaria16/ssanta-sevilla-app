import csv
from sqlalchemy import text
from database import SessionLocal
from models import Dia, Hermandad, InfoPaso, TipoPaso
from datetime import datetime
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_DIR = os.path.join(BASE_DIR, "csv")

def load_dias(db):
    with open(os.path.join(CSV_DIR, "dias.csv"), encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter=";")
        for row in reader:
            dia = Dia(id=int(row['id']), nombre=row['nombre'], fecha=datetime.now())
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


def clear_seed_tables(db):
    db.query(InfoPaso).delete(synchronize_session=False)
    db.query(Hermandad).delete(synchronize_session=False)
    db.query(Dia).delete(synchronize_session=False)
    
    
def reset_auto_increment(db):
    db.execute(text("ALTER TABLE infopaso AUTO_INCREMENT = 1"))
    db.execute(text("ALTER TABLE hermandades AUTO_INCREMENT = 1"))
    db.execute(text("ALTER TABLE dias AUTO_INCREMENT = 1"))
    db.commit()
    print("Reset AUTO_INCREMENT counters")
    
    
def seed_database():
    db = SessionLocal()
    try:
        clear_seed_tables(db)
        reset_auto_increment(db)
        load_dias(db)
        load_hermandades(db)
        load_infopasos(db)
        db.commit()
    except Exception as e:
        db.rollback()
        print(f"Error: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    seed_database()