defmodule Dailyploy.Model.UserStories do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.UserStories
  alias Dailyploy.Schema.StoriesAttachments

  def get(id) when is_integer(id) do
    case Repo.get(UserStories, id) do
      nil ->
        {:error, "not found"}

      user_stories ->
        {:ok, user_stories}
    end
  end

  def create(params) do
    changeset = UserStories.changeset(%UserStories{}, params)

    case Repo.insert(changeset) do
      {:ok, user_stories} ->
        user_stories = Repo.preload(user_stories, [:task_status, :owner])
        {:ok, user_stories}

      {:error, error} ->
        {:error, error}
    end
  end

  def update(%UserStories{} = user_stories, params) do
    changeset = UserStories.changeset(user_stories, params)

    case Repo.update(changeset) do
      {:ok, user_stories} ->
        {:ok, user_stories |> Repo.preload([:task_status, :owner])}

      {:error, message} ->
        {:error, message}
    end
  end

  def create_attachment(data) do
    changeset = StoriesAttachments.changeset(%StoriesAttachments{}, data)
    Repo.insert(changeset)
  end

  def delete_attachments(ids, user_stories) do
    query =
      from stories in StoriesAttachments,
        where: stories.user_stories_id == ^user_stories.id and stories.id in ^ids

    Repo.all(query)
  end

  def delete(user_stories) do
    Repo.delete(user_stories)
  end

  def load_data(user_story, query) do
    user_story
    |> Repo.preload([
      :owner,
      :task_status,
      :comments,
      :attachments,
      :roadmap_checklist,
      task_lists_tasks: query
    ])
  end
end
