defmodule Dailyploy.Model.Tag do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Tag

  @spec list_tags :: any
  def list_tags() do
    Repo.all(Tag)
  end

  def get_tag!(id), do: Repo.get!(Tag, id)

  def get_tag!(id, preloads), do: Repo.get!(Tag, id) |> Repo.preload(preloads)

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
end
