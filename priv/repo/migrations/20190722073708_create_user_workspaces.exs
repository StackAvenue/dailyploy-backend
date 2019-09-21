defmodule Dailyploy.Repo.Migrations.CreateUserWorkspace do
  use Ecto.Migration

  def change do
    create table(:user_workspaces) do
      add :workspace_id, :integer
      add :user_id, :integer
      add :role_id, :integer

      timestamps()
    end
  end
end
