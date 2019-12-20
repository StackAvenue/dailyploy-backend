defmodule Dailyploy.Repo.Migrations.CreateDailyStatusMailSettings do
  use Ecto.Migration

  def change do
    create table(:daily_status_mail_settings) do
      add :is_active, :boolean, default: true
      add :to_mails, {:array, :string}
      add :cc_mails, {:array, :string}
      add :bcc_mails, {:array, :string}
      add :email_text, :text
      add :workspace_id, references(:workspaces)

      timestamps()
    end

    create unique_index(:daily_status_mail_settings, [:workspace_id])
  end
end
