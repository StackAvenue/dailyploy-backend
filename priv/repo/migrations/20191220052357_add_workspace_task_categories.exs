defmodule Dailyploy.Repo.Migrations.AddWorkspaceTaskCategories do
  use Ecto.Migration

  def change do
    create table(:workspace_task_categories) do
      add :workspace_id, references(:workspaces, on_delete: :delete_all)
      add :task_category_id, references(:task_categories, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:workspace_task_categories, [:workspace_id, :task_category_id],
             name: :unique_index_for_workspace_and_category
           )
  end
end
