defmodule Dailyploy.Repo.Migrations.CreateWorkspaces do
  use Ecto.Migration

  def change do
    create table(:workspaces) do
      add :name, :string
      add :type, :integer
      add :company_id, :integer

      timestamps()
    end

    create unique_index(:workspaces, [:name])
  end
end
