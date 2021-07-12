defmodule Dailyploy.Repo.Migrations.AddEstimateToFloatInTaskListsTasks do
  use Ecto.Migration

  def up do
    alter table(:task_list_tasks) do
      modify :estimation, :float
    end
  end

  def down do
    alter table(:task_list_tasks) do
      modify :estimation, :float
    end
  end
end
