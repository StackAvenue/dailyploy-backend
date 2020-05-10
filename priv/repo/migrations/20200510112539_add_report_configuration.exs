defmodule Dailyploy.Repo.Migrations.AddReportConfiguration do
  use Ecto.Migration

  def change do
    create table(:report_configuration) do
      add :is_active, :boolean, default: true
      add :to_mails, {:array, :string}
      add :cc_mails, {:array, :string}
      add :bcc_mails, {:array, :string}
      add :email_text, :text
      add :workspace_id, references(:workspaces)
      add :admin_id, references(:users)
      add :user_ids, {:array, :integer}
      add :project_ids, {:array, :integer}
      add :frequency, :string

      timestamps()
    end
  end
end
