defmodule Dailyploy.Model.Role do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Role
  import Ecto.Query

  @all_roles %{admin: "admin", member: "member"}

  def all_roles, do: @all_roles

  def get_role_by_name!(name) do
    query = from role in Role, where: role.name == ^name
    List.first(Repo.all(query))
  end

  @spec list_roles :: any
  def list_roles() do
    Repo.all(Role)
  end

  def get_role!(id), do: Repo.get!(Role, id)

  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  def delete_role(%Role{} = role) do
    Repo.delete(role)
  end
end
