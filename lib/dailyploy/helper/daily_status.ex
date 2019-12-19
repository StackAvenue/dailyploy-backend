defmodule Dailyploy.Helper.DailyStatus do
  alias SendGrid.{Mail, Email}
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.DailyStatusMailSetting
  alias Dailyploy.Schema.UserWorkspace
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Model.Project, as: ProjectModel
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Model.DailyStatusMailSetting, as: DailyStatusMailSettingsModel

  def schedule_daily_status_mails() do
    daily_status_mail = DailyStatusMailSettingsModel.list_daily_status_mail()

    Enum.each(daily_status_mail, fn daily_status_mail ->
      send_daily_status_mail(daily_status_mail)
    end)
  end

  defp send_daily_status_mail(daily_status_mail) do
    case daily_status_mail.is_active do
      true ->
        bcc_mails = %{}
        cc_mails = %{}

        {:ok, bcc_mails} =
          with false <- is_nil(daily_status_mail.bcc_mails) do
            {:ok, bcc_mails} =
              {:ok, Enum.map(daily_status_mail.bcc_mails, fn x -> %{email: x} end)}
          else
            true ->
              {:ok, %{}}
          end

        {:ok, cc_mails} =
          with false <- is_nil(daily_status_mail.cc_mails) do
            {:ok, cc_mails} = {:ok, Enum.map(daily_status_mail.cc_mails, fn x -> %{email: x} end)}
          else
            true ->
              {:ok, %{}}
          end

        email_build = Email.build()
        mail_list = Enum.map(daily_status_mail.to_mails, fn x -> %{email: x} end)

        email_build =
          email_build
          |> Map.put(:to, mail_list)
          |> Map.put(:bcc, bcc_mails)
          |> Map.put(:cc, cc_mails)

        email_build
        |> Email.put_from("contact@stack-avenue.com")
        |> Email.put_subject("Daily Status Mail")
        |> Email.put_text("Hi Team,
              Below is daily status of user_name for #{daily_status_mail.workspace.name}.
              **Worked On:** -> Worked On
              1.Task_name, From: 8:00 AM to 10:00 AM for project_name **[Done/WIP]** 
              **ToDo** -> Planned but not worked
              1.task_name, for project_name
              
              Thanks,
              Dailyploy Support")
        |> Mail.send()

      false ->
        nil
    end
  end
end
