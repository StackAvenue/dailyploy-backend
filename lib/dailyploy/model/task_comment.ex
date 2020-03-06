defmodule Dailyploy.Model.TaskComment do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.TaskComment

  def get_comment(id, task_id) when is_integer(id) do
    query =
      from(comment in TaskComment,
        where: comment.task_id == ^task_id and comment.id == ^id,
        select: comment
      )

    comment = List.first(Repo.all(query))

    case is_nil(comment) do
      false -> {:ok, comment}
      true -> {:error, "not found"}
    end
  end

  def create_comment(params) do
    changeset = TaskComment.changeset(%TaskComment{}, params)
    Repo.insert(changeset)
  end
end
