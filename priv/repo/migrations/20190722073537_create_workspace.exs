defmodule Dailyploy.Repo.Migrations.CreateWorkspace do
  use Ecto.Migration

  def change do
    create table(:workspaces) do
      add :name, :string
      add :type, :integer
      add :company_id, :integer

      timestamps()
    end
  end
end
