"""Fix enum data consistency in database

Revision ID: 20260225_fix_enum
Revises: 3ee1c0b5b9cd
Create Date: 2026-02-25 12:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '20260225_fix_enum'
down_revision: Union[str, Sequence[str], None] = '3ee1c0b5b9cd'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade - convert all enum data values to uppercase to match database enum type."""
    connection = op.get_bind()
    
    # Convert all data values to uppercase to match the database enum definition
    connection.execute(sa.text("""
        UPDATE infopaso 
        SET tipoPaso = UPPER(tipoPaso)
        WHERE tipoPaso IS NOT NULL
    """))
    
    connection.commit()


def downgrade() -> None:
    """Downgrade - no changes needed since we only normalized casing."""
    pass



