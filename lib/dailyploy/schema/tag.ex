defmodule Dailyploy.Schema.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Label

  schema "tags" do
    field :name, :string
    many_to_many :tasks, Task, join_through: Label

    timestamps()
  end

  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
