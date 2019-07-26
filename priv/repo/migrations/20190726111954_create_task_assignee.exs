defmodule Dailyploy.Repo.Migrations.CreateTaskAssignee do
  use Ecto.Migration

  def change do
    create table(:taskassignees) do
      add :user_id, :integer
      add :task_id, :integer

      timestamps()
    end
    create unique_index(:taskassignees, [:user_id, :task_id], name: :unique_index_for_user_and_task_in_taskassignee)
  end
end
