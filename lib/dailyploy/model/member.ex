defmodule Dailyploy.Model.Member do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Member

  def list_members() do
    Repo.all(Member)
  end

  def get_member!(id), do: Repo.get!(Member, id)

  def get_member!(id, preloads), do: Repo.get!(Member, id) |> Repo.preload(preloads)

  def create_member(attrs \\ %{}) do
    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  def update_member(%Member{} = member, attrs) do
    member
    |> Member.changeset(attrs)
    |> Repo.update()
  end

  def delete_member(%Member{} = member) do
    Repo.delete(member)
  end
end
