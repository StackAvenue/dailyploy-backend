defmodule Dailyploy.Repo.Migrations.AddColumnIdentifierToTaskListTasksTable do
  use Ecto.Migration

  def up do
    alter table(:task_list_tasks) do
      add :identifier, :string
    end
  end

  def down do
    alter table(:task_list_tasks) do
      remove :identifier
    end
  end
end
