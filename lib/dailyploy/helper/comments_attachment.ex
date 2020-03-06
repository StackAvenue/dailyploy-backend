defmodule Dailyploy.Helper.CommentsAttachment do
  alias Dailyploy.Model.CommentsAttachment, as: CAModel
  import DailyployWeb.Helpers

  def create_attachment(params) do
    %{
      comment_id: comment_id,
      image_url: image_url
    } = params

    verify_create(
      CAModel.create_attachment(%{
        comment_id: comment_id,
        image_url: image_url
      })
    )
  end

  defp verify_create({:ok, attachment}) do
    attachment = attachment |> Dailyploy.Repo.preload([:comment])

    %{
      id: attachment.id,
      comment_id: attachment.comment_id,
      image_url: attachment.image_url,
      comment: attachment.comment
    }
  end

  defp verify_create({:error, attachment}) do
    %{error: extract_changeset_error(attachment)}
  end
end
