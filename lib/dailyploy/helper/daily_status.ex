defmodule Dailyploy.Helper.DailyStatus do
  alias SendGrid.{Mail, Email}
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.DailyStatusMailSettings
  alias Dailyploy.Schema.UserWorkspace
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Model.Project, as: ProjectModel
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Model.DailyStatusMailSettings, as: DailyStatusMailSettingsModel

  
  def schedule_daily_status_mails() do
    workspaces = WorkspaceModel.list_workspaces()
    Enum.each workspaces, fn workspaces->
      %Workspace{id: workspace_id, name: workspace_name} = workspaces
      workspace_and_user_selection(workspace_id, workspace_name)
    end
  end

  defp workspace_and_user_selection(workspace_id, workspace_name) do
    user_in_workspace = UserModel.list_users(workspace_id)
    Enum.each user_in_workspace, fn user_in_workspace ->
      %User{id: user_id, name: user_name, email: user_mail} = user_in_workspace
      project_and_task_selection(user_id, user_name, workspace_id, workspace_name, user_mail)
    end
  end

  defp project_and_task_selection(user_id, user_name, workspace_id, workspace_name, user_mail) do
    [%DailyStatusMailSettings{ bcc_mails: bcc_mails, cc_mails: cc_mails, to_mails: to_mails, 
      is_active: is_active, user_workspace_setting_id: user_workspace_setting_id}]
         = DailyStatusMailSettingsModel.daily_status_configuration(workspace_id, user_id)
    
    %Project{name: project_name, id: project_id} = ProjectModel.get_details_of_project(user_workspace_setting_id)        
    %Task{name: task_name} = TaskModel.get_details_of_task(user_workspace_setting_id, project_id)
    send_daily_status_mail(to_mails, bcc_mails, cc_mails, is_active, user_mail, user_name, workspace_name, project_name, task_name)
  end
  
  defp send_daily_status_mail(to_mails, bcc_mails, cc_mails, is_active, from_email, user_name, workspace_name, project_name, task_name) do
    case is_active do
      true ->
        email_build = Email.build()  
        mail_list = Enum.map(to_mails, fn x -> %{email: x} end)
        cc_list = Enum.map(cc_mails, fn x -> %{email: x} end)
        bcc_list = Enum.map(bcc_mails, fn x -> %{email: x} end)
        email_build = 
          email_build 
            |> Map.put(:to, mail_list)
            |> Map.put(:bcc, bcc_list)
            |> Map.put(:cc, cc_list)

        email_build
          |> Email.put_from(from_email) 
          |> Email.put_subject("Daily Status Mail") 
          |> Email.put_text("Hi Team,
              Below is daily status of #{user_name} for #{workspace_name}.
              **Worked On:** -> Worked On
              1.#{task_name}, From: 8:00 AM to 10:00 AM for #{project_name} **[Done/WIP]** 
              **ToDo** -> Planned but not worked
              1.#{task_name}, for #{project_name}
              
              Thanks,
              Dailyploy Support") #task fetch karna he and name and workspace ka naam fetch karna he
          |> Mail.send() 
      false ->  send_resp(conn, 401, "UNAUTHORIZED") 
    
    end    
  end

end