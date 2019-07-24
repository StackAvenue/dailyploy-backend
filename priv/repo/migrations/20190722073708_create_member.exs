defmodule Dailyploy.Repo.Migrations.CreateMember do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :workspace_id, :integer
      add :user_id, :integer
      add :role_id, :integer

      timestamps()
    end
  end
end
