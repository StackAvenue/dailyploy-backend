defmodule Dailyploy.Repo.Migrations.CreateTimeTracking do
  use Ecto.Migration

  def change do
    create table(:time_tracking) do
      add :task_id, references(:tasks, on_delete: :delete_all)
      add :start_time, :utc_datetime
      add :end_time, :utc_datetime
      add :status, :string, null: false
      add :duration, :integer
      timestamps()
    end
  end
end
