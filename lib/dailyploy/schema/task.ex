defmodule Dailyploy.Schema.Task do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Dailyploy.Repo
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.Member

  schema "tasks" do
    field :name, :string
    field :start_datetime, :utc_datetime
    field :end_datetime, :utc_datetime
    field :comments, :string

    belongs_to :project, Project
    many_to_many :members, Member, join_through: "member_tasks"

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> Repo.preload([:members])
    |> cast(attrs, [:name, :start_datetime, :end_datetime, :comments, :project_id])
    |> validate_required([:name, :start_datetime, :end_datetime, :project_id])
    |> unique_constraint(:name)
    |> assoc_constraint(:project)
    |> put_assoc_members(attrs["member_ids"])
  end

  defp put_assoc_members(changeset, member_ids) do
    members = Repo.all(from(member in Member, where: member.id in ^member_ids))

    put_assoc(changeset, :members, Enum.map(members, &change/1))
  end
end
