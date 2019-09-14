defmodule Dailyploy.Repo.Migrations.AddProjectAndWorkspaceAssociation do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :workspace_id, :integer
    end

    drop unique_index(:projects, [:name])

    create unique_index(:projects, [:workspace_id, :name],
             name: :unique_index_for_project_name_and_workspace_id_in_project
           )
  end
end
