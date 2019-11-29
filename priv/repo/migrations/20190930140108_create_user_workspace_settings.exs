defmodule Dailyploy.Repo.Migrations.CreateUserWorkspaceSettings do
  use Ecto.Migration

  def change do
    create table(:user_workspace_settings) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :workspace_id, references(:workspaces, on_delete: :delete_all)

      timestamps()
    end
  end
end
