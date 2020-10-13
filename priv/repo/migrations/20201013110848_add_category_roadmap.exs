defmodule Dailyploy.Repo.Migrations.AddCategoryRoadmap do
  use Ecto.Migration

  def change do
    alter table(:task_lists) do
      add :category_id, references(:task_categories, on_delete: :restrict)
    end
  end
end
