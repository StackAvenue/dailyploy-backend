defmodule Dailyploy.Repo.Migrations.AddCategoryRoadmap do
  use Ecto.Migration

  def up do
    drop constraint(:task_lists, "task_lists_task_status_id_fkey")

    alter table(:task_lists) do
      add :category_id, references(:task_categories, on_delete: :restrict)
      add :status, :string, default: "Planned"
      remove :task_status_id
    end
  end

  def down do
    drop constraint(:task_lists, "task_lists_category_id_fkey")

    alter table(:task_lists) do
      remove :category_id
      remove :status
      add :task_status_id, references(:task_status, on_delete: :restrict)
    end
  end
end
