defmodule Dailyploy.Model.ResourceMember do
  alias Dailyploy.Repo
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Schema.UserWorkspace
  alias Dailyploy.Schema.User

  import Ecto.Query

  def fetch_members(workspace_id) do
    params = %{"workspace_id" => workspace_id}
    query_params = map_to_atom(params)
    members = filter_users(query_params)

    member_results =
      Enum.map(members, fn member ->
        user_workspace_setting =
          UserModel.list_user_workspace_setting(member.id, query_params.workspace_id)

        %{member: member}
      end)
  end

  defp map_to_atom(params) do
    for {key, value} <- params, into: %{}, do: {String.to_atom(key), value}
  end

  defp filter_users(params) do
    query =
      from(user in User,
        join: user_workspace in UserWorkspace,
        on:
          user_workspace.user_id == user.id and
            user_workspace.workspace_id == ^params.workspace_id,
        distinct: true,
        order_by: user.name,
      )

    Repo.all(query)
  end
end
