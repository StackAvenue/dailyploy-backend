defmodule DailyployWeb.ReportController do
  use DailyployWeb, :controller

  alias Dailyploy.Repo
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Model.Project, as: ProjectModel
  alias Dailyploy.Model.TaskCategory, as: TaskCategoryModel
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Avatar

  plug Auth.Pipeline

  def project_summary_report(conn, %{"start_date" => start_date, "end_date" => end_date} = params) do
    params = normalize_start_and_end_date(params)
    report_data = ProjectModel.task_summary_report_data(params)
    render(conn, "project_summary_report.json", report_data: report_data)
  end

  def user_summary_report(conn, %{"start_date" => start_date} = params) do
    params = normalize_start_and_end_date(params)
    report_data = UserModel.task_summary_report_data(params)
    render(conn, "user_summary_report.json", report_data: report_data)
  end

  def categories_summary_report(conn, %{"start_date" => start_date} = params) do
    params = normalize_start_and_end_date(params)
    report_data = TaskCategoryModel.task_summary_report_data(params)
    render(conn, "category_summary_report.json", report_data: report_data)
  end

  def priorities_summary_report(conn, %{"start_date" => start_date} = params) do
    params = normalize_start_and_end_date(params)
    report_data = TaskModel.priority_summary_report_data(params)
    render(conn, "task_summary_report.json", report_data: report_data)
  end

  def index(conn, %{"start_date" => start_date} = params) do
    {:ok, start_date} =
      start_date
      |> Date.from_iso8601()

    end_date =
      case params["frequency"] do
        "daily" ->
          start_date

        "weekly" ->
          Date.add(start_date, 6)

        "monthly" ->
          days = Date.days_in_month(start_date)
          Date.add(start_date, days - 1)
      end

    # user params  convert back to list.  
    # if params["user_ids"] do
    #     params["user_ids"]
    #     |> String.split(",")
    #     |> Enum.map(fn (user_id) -> String.trim user_id end)
    # end

    # if params["project_ids"] do
    #   params["project_ids"]
    #     |> String.split(",")
    #     |> Enum.map(fn (project_id) -> String.trim project_id end)
    # end

    params =
      params
      |> Map.put("start_date", start_date)
      |> Map.put("end_date", end_date)

    reports =
      TaskModel.list_workspace_user_tasks(params)
      |> Repo.preload([:owner, :time_tracks, :category, project: [:owner, :members]])
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

  def csv_download(conn, %{"start_date" => start_date} = params) do
    {:ok, start_date} =
      start_date
      |> Date.from_iso8601()

    end_date =
      case params["frequency"] do
        "daily" ->
          start_date

        "weekly" ->
          Date.add(start_date, 6)

        "monthly" ->
          days = Date.days_in_month(start_date)
          Date.add(start_date, days - 1)
      end

    params =
      params
      |> Map.put("start_date", start_date)
      |> Map.put("end_date", end_date)

    reports =
      TaskModel.list_workspace_user_tasks(params)
      |> Repo.preload([:owner, :time_tracks, :category, project: [:owner, :members]])
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

    NimbleCSV.define(MyParser, separator: "\t", escape: "\"")
    data = [["Date", "Task Name", "Project Name", "Category", "Status", "Priority"]]

    csv_data =
      Enum.reduce(reports, [], fn {date, tasks}, acc ->
        task_acc =
          Enum.reduce(tasks, [], fn task, task_acc ->
            task_acc =
              task_acc ++
                [
                  [
                    date,
                    task.name,
                    task.project.name,
                    task.category.name,
                    task.status,
                    task.priority
                  ]
                ]
          end)

        acc = acc ++ task_acc
      end)

    data = data ++ csv_data
    date = DateTime.utc_now()
    File.write!("#{date}.csv", MyParser.dump_to_iodata(data))
    {:ok, path} = File.cwd()
    path = path <> "/#{date}.csv"
    csv_url = add_csv_url(path)
    render(conn, "csv_download.json", csv_url: csv_url)
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

  defp add_csv_url(path) do
    with {:ok, csv_name} <- Avatar.store({path, "report"}) do
      Avatar.url({csv_name, "report"})
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
end
