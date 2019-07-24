defmodule Dailyploy.Repo.Migrations.AddUniqueIndexForUserAndWorkspaceInMember do
  use Ecto.Migration

  def change do
      create unique_index(:members, [:user_id, :workspace_id], name: :add_unique_index_for_user_and_workspace_in_member)
  end
end
