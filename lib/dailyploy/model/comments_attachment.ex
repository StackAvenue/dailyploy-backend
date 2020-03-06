defmodule Dailyploy.Model.CommentsAttachment do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.CommentsAttachment

  def create_attachment(params) do
    changeset = CommentsAttachment.changeset(%CommentsAttachment{}, params)
    Repo.insert(changeset)
  end
end
