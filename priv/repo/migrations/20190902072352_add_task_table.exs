defmodule Dailyploy.Repo.Migrations.AddTaskTable do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :name, :string
      add :start_datetime, :utc_datetime
      add :end_datetime, :utc_datetime
      add :comments, :text

      add :project_id, references(:projects, [on_delete: :delete_all])

      timestamps()
    end

    create index(:tasks, [:project_id])
    create unique_index(:tasks, [:name])
  end
end
