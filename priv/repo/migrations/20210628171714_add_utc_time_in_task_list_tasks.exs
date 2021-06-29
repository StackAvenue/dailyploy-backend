defmodule Dailyploy.Repo.Migrations.AddUtcTimeInTaskListTasks do
  use Ecto.Migration

  def up do
    alter table(:task_list_tasks) do
      add :start_datetime, :utc_datetime
      add :end_datetime, :utc_datetime
    end
  end

  def down do
    alter table(:task_list_tasks) do
      add :start_datetime, :utc_datetime
      add :end_datetime, :utc_datetime
    end
  end
end
