defmodule DailyployWeb.ReportController do
  use DailyployWeb, :controller

  alias Dailyploy.Repo
  alias Dailyploy.Model.Task, as: TaskModel

  plug Auth.Pipeline

  def index(conn, %{"workspace_id" => workspace_id, "user_id" => user_id, "frequency" => frequency, "start_date" => start_date, "project_ids" => project_ids}) do
    project_ids =
      project_ids
        |> String.split(",")
        |> Enum.map(fn x -> String.trim(x, "[") end)
        |> Enum.map(fn x -> String.trim(x, "]") end)
        |> List.delete("")

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
        |> TaskModel.list_workspace_user_tasks(user_id, start_date, end_date, project_ids)
        |> Repo.preload([:owner, :members, project: [:owner, :members]])
        |> Enum.reduce(%{}, fn task, acc ->

          range_end_date = smaller_date(DateTime.to_date(task.end_datetime), end_date)
          range_start_date = greater_date(DateTime.to_date(task.start_datetime), start_date)

          range_start_date
            |> Date.range(range_end_date)
            |> Enum.reduce(acc, fn date, date_acc ->
              date_acc = Map.put_new(date_acc, Date.to_iso8601(date), [])
              tasks = Map.get(date_acc, Date.to_iso8601(date)) ++ [task]
              Map.put(date_acc, Date.to_iso8601(date), tasks)
            end)
        end)

    render(conn, "index.json", reports: reports)
  end

  defp greater_date(date1, date2) do
    case Date.compare(date1, date2) do
      :lt -> date2
      _ -> date1
    end
  end

  defp smaller_date(date1, date2) do
    case Date.compare(date1, date2) do
      :lt -> date1
      _ -> date2
    end
  end
end
