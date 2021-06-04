defmodule Dailyploy.Repo.Migrations.AddColumnIdentifierToTasksTable do
  use Ecto.Migration
  import Ecto.Query
  alias Dailyploy.Model.Task

  def up do
    alter table(:tasks) do
      add :identifier, :string
    end

    flush()

    Task.get_all()
    |> Enum.each(fn task ->
      identifier =
        if is_nil(task.task_list_tasks_id),
          do: "T-#{task.id}",
          else: "RT-#{task.task_list_tasks_id}"

      Task.update_task(task, %{identifier: identifier})
    end)
  end

  def down do
    alter table(:tasks) do
      remove :identifier
    end
  end
end
