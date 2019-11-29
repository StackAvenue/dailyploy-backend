defmodule Dailyploy.Repo.Migrations.CreateUserWorkspaces do
  use Ecto.Migration

  def change do
    create table(:user_workspaces) do
      add :workspace_id, :integer
      add :user_id, :integer
      add :role_id, :integer

      timestamps()
    end

    create unique_index(:user_workspaces, [:user_id, :workspace_id],
             name: :unique_index_for_user_and_workspace_in_user_workspace
           )
  end
end
