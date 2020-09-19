defmodule Dailyploy.Repo.Migrations.StoriesAttachments do
  use Ecto.Migration

  def change do
    create table(:stories_attachments) do
      add :user_stories_id, references(:user_stories, on_delete: :delete_all)
      add :image_url, :string
      timestamps()
    end
  end
end
