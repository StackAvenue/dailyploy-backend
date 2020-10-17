defmodule Dailyploy.Helper.AddWorkspace do
  alias Dailyploy.Model.Workspace
  alias Dailyploy.Model.UserWorkspace
  alias Dailyploy.Model.UserWorkspaceSetting, as: UWSettingsModel

  def create_workspace(user, params) do
    params = map_to_atom(params)

    case Workspace.create_workspace(%{
           name: params.name,
           type: 0,
           timetrack_enabled: params.timetrack_enabled
         }) do
      {:ok, workspace} ->
        UserWorkspace.create_user_workspace(%{
          workspace_id: workspace.id,
          user_id: user.id,
          role_id: 1
        })

        params = %{user_id: user.id, workspace_id: workspace.id}
        UWSettingsModel.create_user_workspace_settings(params)
        {:ok, workspace}

      {:error, _message} ->
        {:error, "Workspace cannot be created"}
    end
  end

  defp map_to_atom(params) do
    for {key, value} <- params, into: %{}, do: {String.to_atom(key), value}
  end
end
