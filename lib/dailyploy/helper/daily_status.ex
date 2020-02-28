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
  alias DailyployWeb.ReportController, as: RCModel
  import Ecto.Query

  @minute 60
  @hour @minute * 60
  @day @hour * 24
  @week @day * 7
  @divisor [@week, @day, @hour, @minute, 1]

  def schedule_daily_status_mails() do
    daily_status_mails = DailyStatusMailSettingsModel.list_daily_status_mail()

    Enum.each(daily_status_mails, fn daily_status_mail ->
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

        params = %{
          "frequency" => "daily",
          "start_date" => Date.to_string(Date.add(Date.utc_today(), -1)),
          "user_ids" => Integer.to_string(daily_status_mail.user_id),
          "workspace_id" => Integer.to_string(daily_status_mail.workspace_id),
          "end_date" => Date.to_string(Date.add(Date.utc_today(), -1))
        }

        tasks =
          Map.get(RCModel.report_query(params), Date.to_string(Date.add(Date.utc_today(), -1)))

        day_tasks = %{}

        day_tasks =
          case is_nil(tasks) do
            false ->
              Enum.reduce(tasks, %{}, fn task, acc ->
                time_tracks =
                  Map.get(
                    task.date_formatted_time_tracks,
                    Date.to_string(Date.add(Date.utc_today(), -1))
                  )

                duration =
                  case is_nil(
                         Map.get(
                           task.date_formatted_time_tracks,
                           Date.to_string(Date.add(Date.utc_today(), -1))
                         )
                       ) do
                    true ->
                      0

                    false ->
                      calculate_durations(
                        Map.get(
                          task.date_formatted_time_tracks,
                          Date.to_string(Date.add(Date.utc_today(), -1))
                        )
                      )
                  end

                Map.put_new(acc, "#{task.name}", sec_to_str(duration))
              end)

            true ->
              %{}
          end

        email_build
        |> Email.put_from("contact@stack-avenue.com")
        |> Email.put_subject("Daily Status Mail")
        |> Email.put_phoenix_view(DailyployWeb.EmailView)
        |> Email.put_phoenix_template("daily_status_mail.html",
          day_tasks: day_tasks,
          user: daily_status_mail.user
        )
        |> Mail.send()

      false ->
        nil
    end
  end

  defp normalize_start_and_end_date(params) do
    {:ok, start_date} = convert_into_iso8601(params["start_date"])
    {:ok, end_date} = convert_into_iso8601(params["end_date"])

    params
    |> Map.put("start_date", start_date)
    |> Map.put("end_date", end_date)
  end

  defp convert_into_iso8601(date) do
    date
    |> Date.from_iso8601()
  end

  defp calculate_durations(task_list) when is_nil(task_list) == false do
    task_duration =
      Enum.reduce(task_list, 0, fn time_track, acc ->
        case is_nil(time_track.duration) do
          true -> acc
          false -> acc + time_track.duration
        end
      end)
  end

  defp sec_to_str(sec) do
    {_, [s, m, h, d, w]} =
      Enum.reduce(@divisor, {sec, []}, fn divisor, {n, acc} ->
        {rem(n, divisor), [div(n, divisor) | acc]}
      end)

    ["#{w} wk", "#{d} d", "#{h} hr", "#{m} min"]
    |> Enum.reject(fn str -> String.starts_with?(str, "0") end)
    |> Enum.join(", ")
  end
end
