defmodule DailyployWeb.ReportController do
  use DailyployWeb, :controller

  alias Dailyploy.Repo
  alias Dailyploy.Model.Task, as: TaskModel

  plug Auth.Pipeline

  def index(conn, %{"workspace_id" => workspace_id, "user_id" => user_id, "frequency" => frequency, "start_date" => start_date}) do
    {:ok, start_date} =
      start_date
        |> Date.from_iso8601

    end_date =
      case frequency do
        "daily" ->
          start_date
        "weekly" ->
          Date.add(start_date, 6)
        "monthly" ->
          days = Date.days_in_month(start_date)
          Date.add(start_date, days - 1)
      end

    reports =
      workspace_id
        |> TaskModel.list_workspace_user_tasks(user_id, start_date, end_date)
        |> Repo.preload([project: [:members]])
        |> Enum.group_by(fn task ->
          task.start_datetime
            |> DateTime.to_date
            |> Date.to_iso8601
        end)

    render(conn, "index.json", reports: reports)
  end
end
