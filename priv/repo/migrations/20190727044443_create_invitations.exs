defmodule Dailyploy.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table(:invitations) do
      add :email, :string
      add :status, :integer
      add :token, :string
      add :name, :string
      add :working_hours, :integer
      add :role_id, references(:roles)
      add :workspace_id, references(:workspaces)
      add :project_id, references(:projects, on_delete: :delete_all)
      add :assignee_id, references(:users)
      add :sender_id, references(:users)
      timestamps()
    end
  end
end
