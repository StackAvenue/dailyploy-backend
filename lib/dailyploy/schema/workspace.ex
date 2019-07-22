defmodule Dailyploy.Schema.Workspace do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dailyploy.Schema.Company

  schema "workspaces" do
    field :name, :string
    field :type, WorkspaceTypeEnum
    belongs_to :company, Company

    timestamps()
  end

  @doc false
  def changeset(workspace, attrs) do
    workspace
    |> cast(attrs, [:name, :type])
    |> validate_required([:name, :type])
  end
end
