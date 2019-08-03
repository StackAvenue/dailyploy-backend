defmodule Dailyploy.Schema.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.ProjectUser
  alias Dailyploy.Schema.Workspace

  schema "projects" do
    field :name, :string
    field :start_date, :date
    field :description, :string
    field :color_code, :string
    many_to_many :users, User, join_through: ProjectUser
    belongs_to :workspace, Workspace

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :start_date, :description])
    |> validate_required([:name, :start_date])
    |> unique_constraint(:project_name_workspace_uniqueness,
      name: :unique_index_for_project_name_and_workspace_id_in_project
    )
    |> format_start_date(attrs)
    |> put_assoc(:workspace, attrs["workspace"])
    |> put_assoc(:users, attrs["users"])
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
end
