defmodule Dailyploy.Schema.StoriesAttachments do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.{UserStories}

  schema "stories_attachments" do
    belongs_to :user_stories, UserStories
    field(:image_url, :string)
    field(:image, :any, virtual: true)
    timestamps()
  end

  @changeset ~w(image_url user_stories_id)a

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, @changeset)
    |> validate_required(@changeset)
  end
end
