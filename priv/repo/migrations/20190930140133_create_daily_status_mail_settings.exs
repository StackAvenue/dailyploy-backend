defmodule Dailyploy.Repo.Migrations.CreateDailyStatusMailSettings do
  use Ecto.Migration

  def change do
    create table(:daily_status_mail_settings) do
      add :is_active, :boolean, default: true
      add :to_mails, {:array, :string}
      add :cc_mails, {:array, :string}
      add :bcc_mails, {:array, :string}
      add :email_text, :text
      add :user_workspace_setting_id, references(:user_workspace_settings, [on_delete: :delete_all])

      timestamps()
    end

    create unique_index(:daily_status_mail_settings, [:user_workspace_setting_id])
  end
end