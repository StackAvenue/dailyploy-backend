defmodule Dailyploy.Repo.Migrations.AddUniqueIndexForUserAndWorkspaceInUserWorkspace do
  use Ecto.Migration

  def change do
    create unique_index(:user_workspaces, [:user_id, :workspace_id],
             name: :add_unique_index_for_user_and_workspace_in_user_workspace
           )
  end
end
