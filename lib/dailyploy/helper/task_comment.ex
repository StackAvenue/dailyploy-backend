defmodule Dailyploy.Helper.TaskComment do
  alias Dailyploy.Model.TaskComment, as: TCModel
  import DailyployWeb.Helpers

  def create_comment(params) do
    %{
      task_id: task_id,
      user_id: user_id,
      comments: comments
    } = params

    verify_create(
      TCModel.create_comment(%{
        task_id: task_id,
        user_id: user_id,
        comments: comments
      })
    )
  end

  defp verify_create({:ok, comment}) do
    comment = comment |> Dailyploy.Repo.preload([:user, :task])

    {:ok,
     %{
       id: comment.id,
       task_id: comment.task_id,
       user_id: comment.user_id,
       comments: comment.comments,
       user: comment.user,
       task: comment.task
     }}
  end

  defp verify_create({:error, comment}) do
    {:error, %{error: extract_changeset_error(comment)}}
  end
end
