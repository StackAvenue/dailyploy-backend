defmodule Dailyploy.Schema.TaskCategory do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Daily.Repo

  schema "task_categories" do
    field :name, :string

    timestamps()
  end

  def changeset(task_categories, attrs) do
    task_categories
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_format(:name, ~r/^[A-Za-z]/)
  end
end
