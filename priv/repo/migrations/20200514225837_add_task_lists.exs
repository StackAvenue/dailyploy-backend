defmodule Dailyploy.Repo.Migrations.AddTaskLists do
  use Ecto.Migration

  def change do
    create table(:add_task_lists) do
      add :name, :string
      add :description, :text
      add :owner_id, references(:users, on_delete: :delete_all), null: false
      add :category_id, references(:task_categories)
      add :status, :string
      add :priority, :string

      add :project_task_list_id, references(:add_project_task_list, on_delete: :delete_all),
        null: false

      add :estimation, :integer

      timestamps()
    end
  end
end
