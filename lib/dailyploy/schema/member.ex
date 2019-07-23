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
    |> validate_required([:workspace_id, :user_id, :role_id])
  end
end
