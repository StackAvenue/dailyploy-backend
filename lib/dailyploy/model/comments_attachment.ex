defmodule Dailyploy.Model.CommentsAttachment do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.CommentsAttachment

  def create_attachment(params) do
    changeset = CommentsAttachment.changeset(%CommentsAttachment{}, params)
    Repo.insert(changeset)
  end

  def delete_attachment(attachment) do
    Repo.delete(attachment)
  end
end
