defmodule Dailyploy.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string
      add :color, :string
      add :workspace_id, :integer

      timestamps()
    end

    create unique_index(:tags, [:workspace_id, :name],
      name: :unique_index_for_tag_name_and_workspace_in_tag
    )
  end
end
