"""Convert enum values to uppercase

Revision ID: 20260225_convert_to_uppercase
Revises: 20260225_fix_enum
Create Date: 2026-02-25 12:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '20260225_convert_to_uppercase'
down_revision: Union[str, Sequence[str], None] = '20260225_fix_enum'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade - convert all enum data values to UPPERCASE."""
    connection = op.get_bind()
    
    # Convert all data values to uppercase
    connection.execute(sa.text("""
        UPDATE infopaso 
        SET tipoPaso = UPPER(tipoPaso)
        WHERE tipoPaso IS NOT NULL
    """))
    
    connection.commit()


def downgrade() -> None:
    """Downgrade - no changes needed."""
    pass
