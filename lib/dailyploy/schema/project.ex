defmodule Dailyploy.Schema.Project do
  use Ecto.Schema
  alias Dailyploy.Schema.Invitation
  import Ecto.Changeset
  import Ecto.Query

  alias Dailyploy.Repo
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.UserProject
  alias Dailyploy.Schema.Contact
  alias Dailyploy.Schema.Milestone

  schema "projects" do
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    field :description, :string
    field :color_code, :string
    field :monthly_budget, :float

    belongs_to :workspace, Workspace
    belongs_to :owner, User
    has_many :invitation, Invitation
    has_many :tasks, Task
    has_many :contacts, Contact
    has_many :milestones, Milestone
    many_to_many :members, User, join_through: UserProject, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [
      :name,
      :start_date,
      :end_date,
      :description,
      :color_code,
      :owner_id,
      :workspace_id,
      :monthly_budget
    ])
    |> validate_required([:name, :start_date])
    |> format_start_date(attrs)
    |> assoc_constraint(:owner)
    |> assoc_constraint(:workspace)
    |> unique_constraint(:project_name_workspace_uniqueness,
      name: :unique_index_for_project_name_and_workspace_id_in_project
    )
    |> put_project_members(attrs["members"])
  end

  def update_changeset(project, attrs) do
    project
    |> Repo.preload([:members])
    |> cast(attrs, [:name, :start_date, :end_date, :description, :color_code, :monthly_budget])
    |> format_start_date(attrs)
    |> unique_constraint(:project_name_workspace_uniqueness,
      name: :unique_index_for_project_name_and_workspace_id_in_project
    )
    |> put_project_members(attrs["members"])
  end

  defp format_start_date(project, attrs) do
    case DateTime.from_iso8601(attrs["start_date"]) do
      {:ok, datetime, _} ->
        put_change(project, :start_date, DateTime.to_date(datetime))

      _ ->
        add_error(project, :start_date, "Wrong Date Format, please follow iso8601")
    end

    project
  end

  defp put_project_members(changeset, members) do
    members = Repo.all(from(user in User, where: user.id in ^members))

    put_assoc(changeset, :members, Enum.map(members, &change/1))
  end
end
