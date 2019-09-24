defmodule Dailyploy.Schema.UserWorkspace do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Role

  schema "user_workspaces" do
    belongs_to :workspace, Workspace
    belongs_to :user, User
    belongs_to :role, Role

    timestamps()
  end

  def changeset(user_workspace, attrs) do
    user_workspace
    |> cast(attrs, [:workspace_id, :user_id, :role_id])
    |> validate_required([:workspace_id, :user_id])
    |> unique_constraint(:user_workspace_uniqueness,
      name: :unique_index_for_user_and_workspace_in_user_workspace
    )
  end

  def update_role_changeset(user_workspace, role) do
    user_workspace
    |> put_assoc(:role, role)
  end
end
