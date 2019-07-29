defmodule Dailyploy.Repo.Migrations.AddColorAndWorkspaceIdInTag do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      add :color, :string
      add :workspace_id, :integer
    end
    drop unique_index(:tags, [:name])
    create unique_index(:tags, [:workspace_id, :name], name: :unique_index_for_tag_name_and_workspace_in_tag)
  end
end
