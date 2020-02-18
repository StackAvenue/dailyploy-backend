defmodule Dailyploy.Repo.Migrations.AlterDailyStatusMailSettings do
  use Ecto.Migration

  def up do
    drop unique_index(:daily_status_mail_settings, [:workspace_id])
    drop constraint("daily_status_mail_settings", "daily_status_mail_settings_workspace_id_fkey")

    alter table(:daily_status_mail_settings) do
      modify :workspace_id, references(:workspaces, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create unique_index(:daily_status_mail_settings, [:workspace_id, :user_id],
             name: :user_workspace_unique_status
           )
  end

  def down do
    drop unique_index(:daily_status_mail_settings, [:workspace_id, :user_id],
           name: :user_workspace_unique_status
         )

    drop constraint("daily_status_mail_settings", "daily_status_mail_settings_workspace_id_fkey")
    drop constraint("daily_status_mail_settings", "daily_status_mail_settings_user_id_fkey")

    alter table(:daily_status_mail_settings) do
      modify :workspace_id, references(:workspaces, on_delete: :delete_all), null: false
      remove :user_id
    end

    create unique_index(:daily_status_mail_settings, [:workspace_id])
  end
end
