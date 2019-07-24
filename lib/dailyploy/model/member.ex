defmodule Dailyploy.Model.Member do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Member
  import Ecto.Query

  def list_members() do
    Repo.all(Member)
  end

  def get_member!(%{user_id: user_id, workspace_id: workspace_id}) do
    query = from member in Member, where: member.user_id == ^user_id and member.workspace_id == ^workspace_id
    List.first (Repo.all query)
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

  def update_member_role(member, role) do
    member
    |> Member.update_role_changeset(role)
    |> Repo.update()
  end

  def delete_member(%Member{} = member) do
    Repo.delete(member)
  end
end
