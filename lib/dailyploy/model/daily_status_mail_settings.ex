defmodule Dailyploy.Model.DailyStatusMailSettings do
    alias Dailyploy.Repo
    alias Dailyploy.Schema.DailyStatusMailSettings
    alias Dailyploy.Schema.UserWorkspaceSettings
    alias Dailyploy.Model.DailyStatusMailSettings, as: DailyStatusMailSettingsModel
    alias Dailyploy.Model.UserWorkspaceSettings, as: UserWorkspaceSettingsModel
  
  
  def create_daily_status_mail_settings(attrs \\ %{}) do
    %DailyStatusMailSettings{}
    |> DailyStatusMailSettings.changeset(attrs)
    |> Repo.insert()
  end

  def update_daily_status_mail_settings(daily_status_mail_settings, attrs) do
    daily_status_mail_settings
      |> DailyStatusMailSettings.changeset(attrs)
      |> Repo.update()
  end

  def create(user_params) do
       %{"workspace_id" => workspace_id, "bcc_mails" => bcc_mails, "cc_mails" => cc_mails, "to_mails" => to_mails, "is_active" => is_active, "email_text" => email_text} = user_params  
      #%{ "workspace_id" => workspace_id } = user_params
      %UserWorkspaceSettings{ id: id } = UserWorkspaceSettingsModel.get_user_workspace_settings_id(workspace_id)
      params = Map.new()
      params =  Map.put_new(params, :workspace_id, workspace_id)
      params =  Map.put_new(params, :bcc_mails, bcc_mails)
      params =  Map.put_new(params, :cc_mails, cc_mails)
      params =  Map.put_new(params, :to_mails, to_mails)
      params =  Map.put_new(params, :is_active, is_active)
      params =  Map.put_new(params, :email_text, email_text)
      params =  Map.put_new(params, :user_workspace_setting_id, id)
      #something need to be done here
      DailyStatusMailSettingsModel.create_daily_status_mail_settings(params)
  end 

  def stop_and_resume(user_params) do
    %{"user_workspace_settings_id" => user_workspace_settings_id, "is_active" => is_active} = user_params
    query = 
      from user_workspace_settings_id in UserWorkspaceSettings,
      where: user_workspace_settings_id.id == ^user_workspace_settings_id
    # yaha se age karna he
     List.first(Repo.all(query))
  end  


end