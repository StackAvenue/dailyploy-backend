defmodule Dailyploy.Repo.Migrations.AddUserTasks do
  use Ecto.Migration

  def change do
    create table(:user_tasks) do
      add :user_id, references(:users, [on_delete: :delete_all])
      add :task_id, references(:tasks, [on_delete: :delete_all])
    end

    create unique_index(:user_tasks, [:user_id, :task_id],
      name: :unique_index_for_user_and_task_in_user_task
    )
  end
end
