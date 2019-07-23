defmodule Dailyploy.Schema.Workspace do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Company
  alias Dailyploy.Schema.User

  schema "workspaces" do
    field :name, :string
    field :type, WorkspaceTypeEnum

    belongs_to :company, Company
    many_to_many :users, User, join_through: "members"

    timestamps()
  end

  @doc false
  def changeset(workspace, attrs) do
    workspace
    |> cast(attrs, [:name, :type, :company_id])
    |> validate_required([:name, :type, :company_id])
  end
end
