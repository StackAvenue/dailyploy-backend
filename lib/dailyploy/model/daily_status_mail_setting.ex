defmodule Dailyploy.Model.DailyStatusMailSetting do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.DailyStatusMailSetting
  alias Dailyploy.Schema.UserWorkspace
  alias Dailyploy.Schema.UserWorkspaceSetting
  alias Dailyploy.Model.DailyStatusMailSetting, as: DailyStatusMailSettingsModel
  # alias Dailyploy.Model.UserWorkspaceSetting, as: UserWorkspaceSettingsModel
  import Ecto.Query

  def daily_status_configuration(workspace_id, user_id) do
    query =
      from(daily_status_mail_setting in DailyStatusMailSetting,
        join: userworkspacesettings in UserWorkspaceSetting,
        on: userworkspacesettings.id == daily_status_mail_setting.user_workspace_setting_id,
        join: userworkspace in UserWorkspace,
        on:
          userworkspacesettings.user_id == userworkspace.user_id and
            userworkspacesettings.workspace_id == userworkspace.workspace_id,
        where: userworkspace.user_id == ^user_id and userworkspace.workspace_id == ^workspace_id
      )

    Repo.all(query)
  end

  def create_daily_status_mail_settings(attrs \\ %{}) do
    %DailyStatusMailSetting{}
    |> DailyStatusMailSetting.changeset(attrs)
    |> Repo.insert()
  end

  def update_daily_status_mail_settings(daily_status_mail_setting, attrs) do
    daily_status_mail_setting
    |> DailyStatusMailSetting.update_changeset(attrs)
    |> Repo.update()
  end

  def stop_and_resume(user_params) do
    %{"workspace_id" => workspace_id, "is_active" => is_active} = user_params

    query =
      from user_workspace_settings_ids in UserWorkspaceSetting,
        where: user_workspace_settings_ids.workspace_id == ^workspace_id

    %UserWorkspaceSetting{id: id} = List.first(Repo.all(query))

    query =
      from daily_status_mail_setting in DailyStatusMailSetting,
        where: daily_status_mail_setting.user_workspace_setting_id == ^id

    daily_status_mail_setting = List.first(Repo.all(query))

    DailyStatusMailSettingsModel.update_daily_status_mail_settings(daily_status_mail_setting, %{
      "is_active" => is_active
    })
  end

  def get(id) when is_integer(id) do
    query = 
      from daily_status in DailyStatusMailSetting,
      where: daily_status.workspace_id == ^id
    
    with {:ok, daily_status_mail} <- {:ok, List.first(Repo.all(query))} do
      {:ok, daily_status_mail}
    else
      nil ->
        {:error, "not found"}
    end
  end
end
