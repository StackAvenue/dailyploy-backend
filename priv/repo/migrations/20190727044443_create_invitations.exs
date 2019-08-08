defmodule Dailyploy.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table (:invitations) do 
      add :email, :string
      add :type,  :integer
      add :token, :string
      add :workspace_id, references(:workspaces)
      add :project_id, references(:projects)
      add :assignee_id, references(:users)
      add :sender_id, references(:users)
      timestamps()
    end 
  end
end
