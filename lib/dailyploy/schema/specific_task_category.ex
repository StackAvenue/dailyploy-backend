defmodule Dailyploy.Schema.SpecificTaskCategory do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.TaskCategory

  schema "specific_task_categories" do
    timestamps()
  end
end
