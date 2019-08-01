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
    |> unique_constraint(:name)
    |> put_assoc(:workspace, attrs["Workspace"])
  end
end
