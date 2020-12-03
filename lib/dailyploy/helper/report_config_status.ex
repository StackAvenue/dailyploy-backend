defmodule Dailyploy.Helper.ReportConfigStatus do
  alias SendGrid.{Mail, Email}
  alias Dailyploy.Schema.ReportConfiguration
  alias DailyployWeb.ReportController, as: RContro
  alias Dailyploy.Repo
  # import Ecto.Query

  def schedule_weekly_reports() do
    reports = ReportConfiguration |> Repo.all()

    Enum.each(reports, fn report ->
      Task.async(fn -> send_weekly_report(report) end)
    end)
  end

  defp send_weekly_report(report) do
    case report.is_active do
      true ->
        bcc_mails = nil
        cc_mails = nil

        {:ok, bcc_mails} =
          with false <- is_nil(report.bcc_mails) do
            {:ok, bcc_mails} = {:ok, Enum.map(report.bcc_mails, fn x -> %{email: x} end)}
          else
            true ->
              {:ok, nil}
          end

        {:ok, cc_mails} =
          with false <- is_nil(report.cc_mails) do
            {:ok, cc_mails} = {:ok, Enum.map(report.cc_mails, fn x -> %{email: x} end)}
          else
            true ->
              {:ok, nil}
          end

        email_build = Email.build()
        mail_list = Enum.map(report.to_mails, fn x -> %{email: x} end)

        email_build =
          email_build
          |> Map.put(:to, mail_list)
          |> Map.put(:bcc, bcc_mails)
          |> Map.put(:cc, cc_mails)

        %{
          is_active: is_active,
          to_mails: to_mails,
          cc_mails: cc_mails,
          bcc_mails: bcc_mails,
          email_text: email_text,
          workspace_id: workspace_id,
          admin_id: admin_id,
          user_ids: user_ids,
          project_ids: project_ids,
          frequency: frequency
        } = report

        project_ids =
          case is_nil(project_ids) do
            true -> []
            false -> project_ids ++ [0]
          end

        params = %{
          "is_active" => is_active,
          "to_mails" => to_mails,
          "cc_mails" => cc_mails,
          "bcc_mails" => bcc_mails,
          "email_text" => email_text,
          "workspace_id" => workspace_id,
          "admin_id" => admin_id,
          "user_ids" => user_ids,
          "project_ids" => project_ids,
          "frequency" => frequency
        }

        start_date = Timex.beginning_of_week(Date.utc_today())
        params = Map.put_new(params, "start_date", Date.to_string(start_date))

        csv_link = RContro.csv_helper_for_mail(params)

        email_build
        |> Email.put_from("Dailyploy@stack-avenue.com")
        |> Email.put_subject("Here’s Your Weekly Report")
        |> Email.put_phoenix_view(DailyployWeb.EmailView)
        |> Email.put_phoenix_template("weekly_reports.html",
          csv_link: csv_link
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
