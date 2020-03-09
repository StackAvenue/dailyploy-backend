defmodule Dailyploy.Schema.CommentsAttachment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.TaskComment

  schema("comments_attachments") do
    field(:image_url, :string)
    field(:image, :any, virtual: true)
    belongs_to(:task_comment, TaskComment)

    timestamps()
  end

  @changeset ~w(image_url task_comment_id)a

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, @changeset)
    |> validate_required(@changeset)
  end
end
