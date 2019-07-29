defmodule Dailyploy.Schema.Workspace do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Company
  alias Dailyploy.Schema.Member
  alias Dailyploy.Schema.Tag
  alias Dailyploy.Schema.Project

  schema "workspaces" do
    field :name, :string
    field :type, WorkspaceTypeEnum

    belongs_to :company, Company
    has_many :members, Member, on_delete: :delete_all, on_replace: :delete
    has_many :users, through: [:members, :user]
    has_many :tags, Tag
    has_many :projects, Project

    timestamps()
  end

  @doc false
  def changeset(workspace, attrs) do
    workspace
    |> cast(attrs, [:name, :type, :company_id])
    |> validate_required([:name, :type])
  end
end
