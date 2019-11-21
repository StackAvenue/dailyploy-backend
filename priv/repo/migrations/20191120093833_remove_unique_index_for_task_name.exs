defmodule Dailyploy.Repo.Migrations.RemoveUniqueIndexForTaskName do
  use Ecto.Migration

  def up do
    drop unique_index(:tasks, [:name, :project_id],
      name: :unique_index_for_task_name_and_project_id_in_task
    )
  end

  def down do
    create unique_index(:tasks, [:name, :project_id],
      name: :unique_index_for_task_name_and_project_id_in_task
    )
  end
end
