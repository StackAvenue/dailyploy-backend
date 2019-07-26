defmodule Dailyploy.Schema.Label do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Schema.Task
  alias Ecto.Schema.Tag

  schema "labels" do
    belongs_to :tag, Tag
    belongs_to :task, Task

    timestamps()
  end

  def changeset(member, attrs) do
    member
    |> cast(attrs, [:tag_id, :task_id])
    |> validate_required([:tag_id, :task_id])
    |> unique_constraint(:tag_task_uniqueness, name: :unique_index_for_tag_and_task_in_label)
  end
end
