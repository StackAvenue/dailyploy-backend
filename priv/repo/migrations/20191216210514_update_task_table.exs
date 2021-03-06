defmodule Dailyploy.Repo.Migrations.UpdateTaskTable do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :category_id, references(:task_categories, on_delete: :delete_all)
      add :status, :string
      add :priority, :string
    end
  end
end
