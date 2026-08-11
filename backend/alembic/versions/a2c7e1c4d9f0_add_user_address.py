"""add user address

Revision ID: a2c7e1c4d9f0
Revises: 74a211461cc6
"""

import sqlalchemy as sa
from alembic import op


revision = "a2c7e1c4d9f0"
down_revision = "74a211461cc6"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("users", sa.Column("address", sa.String(length=255), nullable=True))


def downgrade() -> None:
    op.drop_column("users", "address")
