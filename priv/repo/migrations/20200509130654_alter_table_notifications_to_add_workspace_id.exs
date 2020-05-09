defmodule Dailyploy.Repo.Migrations.AlterTableNotificationsToAddWorkspaceId do
  use Ecto.Migration

  def up do
    alter table(:notifications) do
      add(:workspace_id, references(:workspaces))
    end
  end

  def down do
    drop constraint("notifications", "notifications_workspace_id_fkey")
    
    alter table(:notifications) do
      remove(:workspace_id)
    end
  end
end
