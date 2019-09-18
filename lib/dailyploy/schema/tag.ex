defmodule Dailyploy.Schema.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Label
  alias Dailyploy.Schema.Workspace

  schema "tags" do
    field :name, :string
    field :color, :string
    belongs_to :workspace, Workspace, on_replace: :update
    many_to_many :tasks, Task, join_through: Label

    timestamps()
  end

  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :color])
    |> validate_required([:name])
    |> unique_constraint(:tag_name_workspace_uniqueness,
      name: :unique_index_for_tag_name_and_workspace_in_tag
    )
    |> put_assoc(:workspace, attrs["workspace"])
  end
end
