defmodule Dailyploy.Repo.Migrations.AlterInvitationsTable do
  use Ecto.Migration

  def up do
    alter table(:invitations) do
      add :hourly_expense, :float, default: 0
    end
  end

  def down do
    alter table(:invitations) do
      remove :hourly_expense
    end
  end
end
