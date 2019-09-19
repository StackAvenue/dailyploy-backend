defmodule Dailyploy.Schema.Project do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Dailyploy.Repo
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.UserProject
  alias Dailyploy.Schema.Workspace

  schema "projects" do
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    field :description, :string
    field :color_code, :string
    many_to_many :members, User, join_through: UserProject
    belongs_to :workspace, Workspace
    belongs_to :owner, User

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :start_date, :end_date, :description, :color_code, :owner_id, :workspace_id])
    |> validate_required([:name, :start_date])
    |> unique_constraint(:project_name_workspace_uniqueness,
      name: :unique_index_for_project_name_and_workspace_id_in_project
    )
    |> format_start_date(attrs)
    |> assoc_constraint(:owner)
    |> assoc_constraint(:workspace)
    |> put_project_members(attrs["members"])
    # |> put_assoc(:workspace, attrs["workspace"])
    # |> put_assoc(:users, attrs["users"])
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
    members = Repo.all(from(user in User, where: user.email in ^members))

    put_assoc(changeset, :members, Enum.map(members, &change/1))
  end

end
