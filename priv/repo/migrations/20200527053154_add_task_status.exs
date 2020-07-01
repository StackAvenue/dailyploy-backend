defmodule Dailyploy.Repo.Migrations.AddTaskStatus do
  use Ecto.Migration

  def up do
    create table(:task_status) do
      add :name, :string, null: false
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      add :workspace_id, references(:workspaces, on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index(:task_status, [:project_id, :name, :workspace_id],
             name: :unique_status_index
           )

    alter table(:tasks) do
      remove :status
      add :status_id, references(:task_status, on_delete: :restrict)
    end
  end

  def down do
    drop constraint(:tasks, "tasks_status_id_fkey")

    alter table(:tasks) do
      remove :status_id
      add :status, :string
    end

    drop table(:task_status)
  end
end
