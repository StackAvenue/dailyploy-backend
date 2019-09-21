defmodule Dailyploy.Repo.Migrations.AddUserTask do
  use Ecto.Migration

  def change do
    create table(:user_tasks) do
      add :user_id, references(:users, [on_delete: :delete_all])
      add :task_id, references(:tasks, [on_delete: :delete_all])
    end

    create index(:user_tasks, [:user_id, :task_id])
  end
end
