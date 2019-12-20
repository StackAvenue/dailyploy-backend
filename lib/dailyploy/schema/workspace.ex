defmodule Dailyploy.Schema.Workspace do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Company
  alias Dailyploy.Schema.Invitation
  alias Dailyploy.Schema.UserWorkspace
  alias Dailyploy.Schema.Tag
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.TaskCategory
  alias Dailyploy.Schema.WorkspaceTaskCategory

  schema "workspaces" do
    field :name, :string
    field :type, WorkspaceTypeEnum

    belongs_to :company, Company
    has_many :invitation, Invitation
    has_many :user_workspaces, UserWorkspace, on_delete: :delete_all, on_replace: :delete
    has_many :users, through: [:user_workspaces, :user]
    has_many :tags, Tag
    has_many :projects, Project
    many_to_many :task_categories, TaskCategory, join_through: WorkspaceTaskCategory
    timestamps()
  end

  @doc false
  def changeset(workspace, attrs) do
    workspace
    |> cast(attrs, [:name, :type, :company_id])
    |> validate_required([:name, :type])
  end
end
