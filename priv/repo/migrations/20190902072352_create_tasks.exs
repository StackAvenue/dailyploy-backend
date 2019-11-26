defmodule Dailyploy.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :name, :string
      add :start_datetime, :utc_datetime
      add :end_datetime, :utc_datetime
      add :comments, :text

      add :project_id, references(:projects, on_delete: :delete_all)
      add :owner_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:tasks, [:project_id, :owner_id])

    create unique_index(:tasks, [:name, :project_id],
             name: :unique_index_for_task_name_and_project_id_in_task
           )
  end
end
