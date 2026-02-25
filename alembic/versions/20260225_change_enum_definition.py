"""Change enum type definition to uppercase

Revision ID: 20260225_change_enum_definition
Revises: 20260225_convert_to_uppercase
Create Date: 2026-02-25 13:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '20260225_change_enum_definition'
down_revision: Union[str, Sequence[str], None] = '20260225_convert_to_uppercase'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade - change enum type definition from mixed case to uppercase."""
    connection = op.get_bind()
    
    # For MySQL, we need to modify the column with the new enum values
    connection.execute(sa.text("""
        ALTER TABLE infopaso MODIFY COLUMN tipoPaso ENUM('CRUZGUIA', 'PALIO', 'DUELO', 'PASO') NOT NULL
    """))
    
    connection.commit()


def downgrade() -> None:
    """Downgrade - revert to original enum type definition."""
    connection = op.get_bind()
    
    connection.execute(sa.text("""
        ALTER TABLE infopaso MODIFY COLUMN tipoPaso ENUM('CruzGuia', 'Palio', 'Duelo', 'Paso') NOT NULL
    """))
    
    connection.commit()
