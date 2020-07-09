defmodule Dailyploy.Repo.Migrations.AddTaskLists do
  use Ecto.Migration

  def change do
    create table(:task_list_tasks) do
      add :name, :string
      add :description, :text
      add :owner_id, references(:users, on_delete: :delete_all), null: false
      add :category_id, references(:task_categories)
      add :status, :string
      add :priority, :string

      add :task_lists_id, references(:task_lists, on_delete: :delete_all), null: false
      add :task_id, references(:tasks, on_delete: :restrict)
      add :estimation, :integer

      timestamps()
    end

    alter table(:tasks) do
      add :estimation, :integer
      add :task_list_tasks_id, references(:task_list_tasks, on_delete: :restrict)
    end
  end
end
