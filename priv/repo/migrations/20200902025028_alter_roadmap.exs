defmodule Dailyploy.Repo.Migrations.AlterRoadmap do
  use Ecto.Migration

  def change do
    alter table(:task_lists) do
      add :task_status_id, references(:task_status, on_delete: :restrict)
    end
  end
end
