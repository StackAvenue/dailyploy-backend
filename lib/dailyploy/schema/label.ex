defmodule Dailyploy.Schema.Label do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Tag

  schema "labels" do
    belongs_to :tag, Tag
    belongs_to :task, Task

    timestamps()
  end

  def changeset(label, attrs) do
    label
    |> unique_constraint(:tag_task_uniqueness, name: :unique_index_for_tag_and_task_in_label)
    |> put_assoc(:tag, attrs["tag"])
    |> put_assoc(:task, attrs["task"])
  end
end
