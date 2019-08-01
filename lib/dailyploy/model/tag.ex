defmodule Dailyploy.Model.Tag do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Tag

  @spec list_tags :: any
  def list_tags() do
    Repo.all(Tag)
  end

  def get_tag!(id), do: Repo.get(Tag, id)

  def get_tag!(id, preloads), do: Repo.get(Tag, id) |> Repo.preload(preloads)

  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  def get_tag_in_workspace!(%{workspace_id: workspace_id, tag_id: tag_id}) do
    query = from tag in Tag, where: tag.workspace_id == ^workspace_id and tag.id == ^tag_id
    List.first Repo.all(query)
  end

  def get_tag_in_workspace!(%{workspace_id: workspace_id, tag_id: tag_id}, preloads) do
    query = from tag in Tag, where: tag.workspace_id == ^workspace_id and tag.id == ^tag_id
    tags = Repo.all(query)
    List.first Repo.preload(tags, preloads)
  end

  def list_tags_in_workspace(%{workspace_id: workspace_id}) do
    query = from tag in Tag, where: tag.workspace_id == ^workspace_id
    Repo.all(query)
  end
end
