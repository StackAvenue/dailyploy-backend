defmodule Dailyploy.Helper.TaskComment do
  alias SendGrid.{Mail, Email}
  alias Dailyploy.Model.TaskComment, as: TCModel
  alias Dailyploy.Repo
  import DailyployWeb.Helpers

  def create_comment(params) do
    %{
      task_id: task_id,
      user_stories_id: user_stories_id,
      user_id: user_id,
      comments: comments
    } = params

    verify_create(
      TCModel.create_comment(%{
        task_id: task_id,
        user_id: user_id,
        user_stories_id: user_stories_id,
        comments: comments
      })
    )
  end

  defp verify_create({:ok, comment}) do
    comment =
      comment |> Dailyploy.Repo.preload([:user, :user_stories, :task, task: [:members, :owner]])

    {:ok,
     %{
       id: comment.id,
       task_id: comment.task_id,
       user_id: comment.user_id,
       comments: comment.comments,
       user: comment.user,
       task: comment.task,
       user_stories: comment.user_stories,
       inserted_at: comment.inserted_at
     }}
  end

  defp verify_create({:error, comment}) do
    {:error, %{error: extract_changeset_error(comment)}}
  end

  # def send_activity_mail(comment) do
  #   email_build =
  #     Email.build()
  #     |> Map.put

  # end
end
