defmodule Dailyploy.Repo.Migrations.AlterUserWorkspaceSettingsTable do
  use Ecto.Migration

  def up do
    alter table(:user_workspace_settings) do
      add :hourly_expense, :float, default: 0
    end
  end

  def down do
    alter table(:user_workspace_settings) do
      remove :hourly_expense
    end
  end
end
