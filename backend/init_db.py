from database import Base, engine
from models import Usuario, Itinerario, Noticia, Emisora, Hermandad, InfoPaso

Base.metadata.drop_all(bind=engine)
Base.metadata.create_all(bind=engine)

print("Tablas eliminadas y creadas correctamente.")