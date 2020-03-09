defmodule Dailyploy.Helper.CommentsAttachment do
  alias Dailyploy.Model.CommentsAttachment, as: CAModel
  import DailyployWeb.Helpers

  def create_attachment(params) do
    %{
      task_comment_id: task_comment_id,
      image_url: image_url
    } = params

    verify_create(
      CAModel.create_attachment(%{
        task_comment_id: task_comment_id,
        image_url: image_url
      })
    )
  end

  defp verify_create({:ok, attachment}) do
    %{
      id: attachment.id,
      task_comment_id: attachment.task_comment_id,
      image_url: attachment.image_url
    }
  end

  defp verify_create({:error, attachment}) do
    %{error: extract_changeset_error(attachment)}
  end
end
