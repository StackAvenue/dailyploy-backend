defmodule Dailyploy.Repo.Migrations.AddUserWorkspaceTask do
  use Ecto.Migration

  def change do
    create table(:user_workspace_tasks) do
      add :user_workspace_id, references(:user_workspaces, [on_delete: :delete_all])
      add :task_id, references(:tasks, [on_delete: :delete_all])
    end

    create index(:user_workspace_tasks, [:user_workspace_id, :task_id])
  end
end
