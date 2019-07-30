defmodule Dailyploy.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table (:invitations) do 
    add :email, :string
    add workspace_id, references(:workspaces)
    end 
  end
end
