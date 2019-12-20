defmodule Dailyploy.Repo.Migrations.AddWorkspaceTaskCategories do
  use Ecto.Migration

  def change do
    create table(:workspace_task_categories) do
      add :workspace_id, references(:workspaces, on_delete: :delete_all)
      add :task_id, references(:tasks, on_delete: :delete_all)
      add :category_id, references(:task_categories)
    end
  end
end
