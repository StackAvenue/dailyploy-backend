defmodule Dailyploy.Repo.Migrations.AddUpdateMemberSettingsInWorkspace do
  use Ecto.Migration

  def up do
    alter table(:user_workspace_settings) do
      add :working_hours, :integer 
    end
  end

  def down do
    alter table(:user_workspace_settings) do
      remove :working_hours, :integer
    end 
  end
end
