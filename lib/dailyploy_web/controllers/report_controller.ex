defmodule DailyployWeb.ReportController do
  use DailyployWeb, :controller

  alias Dailyploy.Repo
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Model.Project, as: ProjectModel
  alias Dailyploy.Model.TaskCategory, as: TaskCategoryModel
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Avatar
  alias Dailyploy.Model.TimeTracking, as: TTModel

  plug Auth.Pipeline

  @minute 60
  @hour @minute * 60
  @day @hour * 24
  @week @day * 7
  @divisor [@week, @day, @hour, @minute, 1]

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
        [range_end_date, range_start_date] =
          if(Enum.empty?(task.time_tracks)) do
            range_end_date = smaller_date(DateTime.to_date(task.end_datetime), end_date)
            range_start_date = greater_date(DateTime.to_date(task.start_datetime), start_date)
            [range_end_date, range_start_date]
          else
            first_time_track = task.time_tracks |> List.first()
            last_time_track = task.time_tracks |> List.last()

            task_start_date =
              smaller_date(task.start_datetime, first_time_track.start_time)
              |> DateTime.to_date()

            task_end_date =
              greater_date(task.end_datetime, last_time_track.start_time)
              |> DateTime.to_date()

            range_start_date = smaller_date(task_start_date, end_date)
            range_end_date = greater_date(task_end_date, start_date)
            [range_end_date, range_start_date]
          end

        date_formatted_time_tracks = date_wise_orientation(task.time_tracks)
        # Enum.reduce(task.time_tracks, %{}, fn time_track, time_acc ->
        #   time_track_range_start_date =
        #     smaller_date(DateTime.to_date(time_track.start_time), start_date)

        #   time_track_range_end_date =
        #     case is_nil(time_track.end_time) do
        #       true -> time_track_range_start_date
        #       false -> greater_date(DateTime.to_date(time_track.end_time), end_date)
        #     end

        #   time_track_range_start_date
        #   |> Date.range(time_track_range_end_date)
        #   |> Enum.reduce(time_acc, fn date, date_acc ->
        #     time_track =
        #       case Map.has_key?(date_acc, Date.to_iso8601(date)) do
        #         true ->
        #           Map.get(date_acc, Date.to_iso8601(date)) ++ [time_track]

        #         false ->
        #           date_acc = Map.put_new(date_acc, Date.to_iso8601(date), [])
        #           Map.get(date_acc, Date.to_iso8601(date)) ++ [time_track]
        #       end

        #     Map.put(date_acc, Date.to_iso8601(date), time_track)
        #   end)
        # end)
        task = Map.put(task, :date_formatted_time_tracks, date_formatted_time_tracks)
        # duration =
        #   with false <- is_nil(TTModel.calculate_task_duration(task.id)) do
        #     TTModel.calculate_task_duration(task.id)
        #   else
        #     true -> 0
        #   end

        # duration = sec_to_str(duration)
        # task = Map.put_new(task, :duration, duration)

        range_start_date
        |> Date.range(range_end_date)
        |> Enum.reduce(acc, fn date, date_acc ->
          date_acc = Map.put_new(date_acc, Date.to_iso8601(date), [])

          is_time_track_present =
            task.time_tracks
            |> Enum.map(fn x ->
              time_track_date = DateTime.to_date(x.start_time)

              if(Date.diff(time_track_date, date) === 0) do
                true
              end
            end)

          if(
            Enum.member?(is_time_track_present, true) or
              Date.diff(task.start_datetime, date) === 0 or
              Enum.empty?(task.time_tracks) or
              (Date.diff(range_end_date, task.end_datetime) >= 0 and
                 Date.diff(range_start_date, task.start_datetime) <= 0 and
                 Enum.member?(
                   Date.range(
                     DateTime.to_date(task.start_datetime),
                     DateTime.to_date(task.end_datetime)
                   ),
                   date
                 ))
          ) do
            duration =
              case is_nil(Map.get(task.date_formatted_time_tracks, Date.to_iso8601(date))) do
                true ->
                  0

                false ->
                  calculate_durations(
                    Map.get(task.date_formatted_time_tracks, Date.to_iso8601(date))
                  )
              end

            #duration = sec_to_str(duration)
            task = Map.put_new(task, :duration, duration)
            tasks = Map.get(date_acc, Date.to_iso8601(date)) ++ [task]
            Map.put(date_acc, Date.to_iso8601(date), tasks)
          else
            date_acc
          end
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
        [range_end_date, range_start_date] =
          if(Enum.empty?(task.time_tracks)) do
            range_end_date = smaller_date(DateTime.to_date(task.end_datetime), end_date)
            range_start_date = greater_date(DateTime.to_date(task.start_datetime), start_date)
            [range_end_date, range_start_date]
          else
            first_time_track = task.time_tracks |> List.first()
            last_time_track = task.time_tracks |> List.last()

            task_start_date =
              smaller_date(task.start_datetime, first_time_track.start_time)
              |> DateTime.to_date()

            task_end_date =
              greater_date(task.end_datetime, last_time_track.start_time)
              |> DateTime.to_date()

            range_start_date = smaller_date(task_start_date, end_date)
            range_end_date = greater_date(task_end_date, start_date)
            [range_end_date, range_start_date]
          end

        date_formatted_time_tracks = date_wise_orientation(task.time_tracks)
        task = Map.put(task, :date_formatted_time_tracks, date_formatted_time_tracks)

        range_start_date
        |> Date.range(range_end_date)
        |> Enum.reduce(acc, fn date, date_acc ->
          date_acc = Map.put_new(date_acc, Date.to_iso8601(date), [])

          is_time_track_present =
            task.time_tracks
            |> Enum.map(fn x ->
              time_track_date = DateTime.to_date(x.start_time)

              if(Date.diff(time_track_date, date) === 0) do
                true
              end
            end)

          if(
            Enum.member?(is_time_track_present, true) or
              Date.diff(task.start_datetime, date) === 0 or
              Enum.empty?(task.time_tracks) or
              (Date.diff(range_end_date, task.end_datetime) >= 0 and
                 Date.diff(range_start_date, task.start_datetime) <= 0 and
                 Enum.member?(
                   Date.range(
                     DateTime.to_date(task.start_datetime),
                     DateTime.to_date(task.end_datetime)
                   ),
                   date
                 ))
          ) do
            duration =
              case is_nil(Map.get(task.date_formatted_time_tracks, Date.to_iso8601(date))) do
                true ->
                  0

                false ->
                  calculate_durations(
                    Map.get(task.date_formatted_time_tracks, Date.to_iso8601(date))
                  )
              end

            duration = sec_to_str(duration)
            task = Map.put_new(task, :duration, duration)
            tasks = Map.get(date_acc, Date.to_iso8601(date)) ++ [task]
            Map.put(date_acc, Date.to_iso8601(date), tasks)
          else
            date_acc
          end
        end)
      end)

    NimbleCSV.define(MyParser, separator: "\t", escape: "\"")
    data = [["Date", "Task Name", "Project Name", "Category", "Status", "Priority", "Duration"]]

    reports

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
                    task.priority,
                    task.duration
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
    File.rm!("#{date}.csv")
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

  def to_str(time) do
    to_str(time, :ms)
  end

  def to_str(time, :ms) do
    ms_to_str(time)
  end

  def to_str(time, :seconds) do
    sec_to_str(time)
  end

  def sec_to_str(sec) do
    {_, [s, m, h, d, w]} =
      Enum.reduce(@divisor, {sec, []}, fn divisor, {n, acc} ->
        {rem(n, divisor), [div(n, divisor) | acc]}
      end)

    ["#{w} wk", "#{d} d", "#{h} hr", "#{m} min", "#{s} sec"]
    |> Enum.reject(fn str -> String.starts_with?(str, "0") end)
    |> Enum.join(", ")
  end

  defp ms_to_str(ms), do: (ms / 1_000) |> sec_to_str()

  defp calculate_durations(task_list) when is_nil(task_list) == false do
    task_duration =
      Enum.reduce(task_list, 0, fn time_track, acc ->
        case is_nil(time_track.duration) do
          true -> acc
          false -> acc + time_track.duration
        end
      end)
  end

  defp date_wise_orientation(task_list) do
    Enum.reduce(task_list, %{}, fn time_track, acc ->
      case Map.has_key?(acc, Date.to_iso8601(time_track.start_time)) do
        true ->
          time_track_add = Map.get(acc, Date.to_iso8601(time_track.start_time)) ++ [time_track]
          acc = Map.replace!(acc, Date.to_iso8601(time_track.start_time), time_track_add)

        false ->
          acc = Map.put_new(acc, Date.to_iso8601(time_track.start_time), [])
          time_track_new = Map.get(acc, Date.to_iso8601(time_track.start_time)) ++ [time_track]
          acc = Map.replace!(acc, Date.to_iso8601(time_track.start_time), time_track_new)
      end
    end)
  end
end
