defmodule Dailyploy.Model.DailyStatusMailSettings do
    alias Dailyploy.Repo
    alias Dailyploy.Schema.DailyStatusMailSettings
    alias Dailyploy.Schema.UserWorkspace
    alias Dailyploy.Schema.UserWorkspaceSettings
    alias Dailyploy.Model.DailyStatusMailSettings, as: DailyStatusMailSettingsModel
    #alias Dailyploy.Model.UserWorkspaceSettings, as: UserWorkspaceSettingsModel
    import Ecto.Query
  
  
  def daily_status_configuration(workspace_id, user_id) do
    query =
      from(daily_status_mail_setting in DailyStatusMailSettings,
      join: userworkspacesettings in UserWorkspaceSettings,
      on:  userworkspacesettings.id == daily_status_mail_setting.user_workspace_setting_id,
      join: userworkspace in UserWorkspace,
      on: userworkspacesettings.user_id == userworkspace.user_id and userworkspacesettings.workspace_id == userworkspace.workspace_id,
      where: userworkspace.user_id == ^user_id and userworkspace.workspace_id == ^workspace_id     
      )
       
    Repo.all(query)
  end
  
  def create_daily_status_mail_settings(attrs \\ %{}) do
    %DailyStatusMailSettings{}
      |> DailyStatusMailSettings.changeset(attrs)
      |> Repo.insert()
  end

  def update_daily_status_mail_settings(daily_status_mail_setting, attrs) do
    daily_status_mail_setting
      |> DailyStatusMailSettings.update_changeset(attrs)
      |> Repo.update()
  end

  def stop_and_resume(user_params) do
    %{"workspace_id" => workspace_id, "is_active" => is_active} = user_params
    query = 
      from user_workspace_settings_ids in UserWorkspaceSettings,
      where: user_workspace_settings_ids.workspace_id == ^workspace_id
  
    %UserWorkspaceSettings{id: id} = List.first(Repo.all(query))

    query =
      from daily_status_mail_setting in DailyStatusMailSettings,
      where: daily_status_mail_setting.user_workspace_setting_id == ^id

    daily_status_mail_setting = List.first(Repo.all(query))
    DailyStatusMailSettingsModel.update_daily_status_mail_settings(daily_status_mail_setting, %{"is_active" => is_active})
    
  end  


end