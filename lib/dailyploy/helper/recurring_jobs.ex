defmodule Dailyploy.Helper.RecurringJobs do
  alias Dailyploy.Repo
  alias Dailyploy.Model.RecurringTask, as: RTModel
  alias Dailyploy.Model.Task, as: TaskModel
  import DailyployWeb.Helpers

  days = %{
    "1" => "Monday",
    "2" => "Tuesday",
    "3" => "Wednesday",
    "4" => "Thursday",
    "5" => "Friday",
    "6" => "Saturday",
    "7" => "Sunday"
  }

  def task_analysis(params) do
    with true <-
           Date.utc_today() in Date.range(
             DateTime.to_date(params.start_datetime),
             Timex.end_of_month(Timex.today())
           ) and params.schedule,
         do: create_task_for_current_month(params)
  end

  defp create_task_for_current_month(params) do
    end_date =
      if Date.diff(Timex.end_of_month(Timex.today()), DateTime.to_date(params.end_datetime)) >= 0 do
        DateTime.to_date(params.end_datetime)
      else
        Timex.end_of_month(Timex.today())
      end

    range = Date.range(DateTime.to_date(params.start_datetime), end_date)

    case params.frequency do
      "daily" -> create_daily_task(params, range)
      "weekly" -> create_weekly_task(params, range)
      "monthly" -> create_monthly_task(params, range)
    end
  end

  defp create_daily_task(params, range) do
    Enum.each(range, fn date ->
      task_creation(params, Timex.to_datetime(date))
    end)
  end

  defp create_weekly_task(params, range) do
  end

  defp create_monthly_task(params, range) do
  end

  defp task_creation(params, date) do
    for {key, value} <- params.project_members_combination do
      if List.first(value) != nil, do: create_task(params, date, key, value)
    end
  end

  defp create_task(params, date, key, value) do
    task_params = %{
      "category_id" => params.category_id,
      "comments" => params.comments,
      "end_datetime" => date,
      "member_ids" => value,
      "name" => params.name,
      "owner_id" => List.first(value),
      "priority" => params.priority,
      "project_id" => key,
      "start_datetime" => date
    }

    asd = TaskModel.create_task(task_params)
  end
end
