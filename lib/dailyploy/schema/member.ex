defmodule Dailyploy.Schema.Member do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Role

  schema "members" do
    belongs_to :workspace, Workspace
    belongs_to :user, User
    belongs_to :role, Role

    timestamps()
  end

  def changeset(member, attrs) do
    member
    |> cast(attrs, [:workspace_id, :user_id, :role_id])
    |> validate_required([:workspace_id, :user_id])
    |> unique_constraint(:user_workspace_uniqueness,
      name: :add_unique_index_for_user_and_workspace_in_member
    )
  end

  def update_role_changeset(member, role) do
    member
    |> put_assoc(:role, role)
  end
end
