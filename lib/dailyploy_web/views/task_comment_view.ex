defmodule DailyployWeb.TaskCommentView do
  use DailyployWeb, :view
  alias DailyployWeb.TaskCommentView
  alias DailyployWeb.ErrorHelpers

  def render("changeset_error.json", %{error: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end

  def render("comment.json", %{comment: comment}) do
    %{
      id: comment.id,
      task_id: comment.task_id,
      user_id: comment.user_id,
      attachments: render_many(comment.attachments, TaskCommentView, "attachment.json"),
      comments: comment.comments
    }
  end

  def render("attachment.json", %{task_comment: attachment}) do
    %{
      attachment_id: attachment.id,
      imge_url: attachment.image_url
    }
  end
end
