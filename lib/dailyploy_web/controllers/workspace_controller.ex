defmodule DailyployWeb.WorkspaceController do
  use DailyployWeb, :controller

  import Ecto.Query

  alias Dailyploy.Repo
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Model.User, as: UserModel

  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.TimeTracking

  @minute 60
  @hour @minute * 60
  @day @hour * 24
  @week @day * 7
  @divisor [@week, @day, @hour, @minute, 1]

  plug Auth.Pipeline
  plug :put_view, DailyployWeb.UserView when action in [:user_tasks]
  plug :put_view, DailyployWeb.TaskView when action in [:project_tasks]

  action_fallback DailyployWeb.FallbackController

  def index(conn, _) do
    user = Guardian.Plug.current_resource(conn)

    workspace_admin_query = UserModel.get_admin_user_query()

    workspaces =
      WorkspaceModel.all_user_workspaces(user)
      |> Repo.preload([:company, users: workspace_admin_query])

    render(conn, "index.json", workspaces: workspaces)
  end

  def user_tasks(conn, %{
        "workspace_id" => workspace_id,
        "frequency" => frequency,
        "start_date" => start_date
      }) do
    # query params keys are converted from string format to atom
    query_params = map_to_atom(conn.query_params)
    # start and end date over which task need to get displayed
    {start_date, end_date} = select_dates(start_date, frequency)
    # project ids are extracted
    project_ids = get_project_ids(conn.query_params)
    # based on start date and end date query is made to extract out task in the given dashboard
    query = create_query(project_ids, workspace_id, start_date, end_date)

    # here the above query is being preloaded for each and every user
    users = get_users(query_params, query, workspace_id)

    # users = users |> Repo.preload(tasks: [time_tracks: query])

    users =
      Enum.reduce(users, [], fn user, acc ->
        tasks =
          Enum.reduce(user.tasks, [], fn task, task_acc ->
            temp_variable = Enum.map(task_acc, fn entered_task -> entered_task.id == task.id end)

            case Enum.member?(temp_variable, true) do
              true -> task_acc
              false -> task_acc ++ [task]
            end
          end)

        user = Map.replace!(user, :tasks, tasks)
        acc ++ [user]
      end)

    query = from time_track in TimeTracking, order_by: [desc: time_track.inserted_at]

    users =
      Enum.map(users, fn user ->
        # user_id_list = Map.fetch!(task_id_list, user.id)
        date_formatted_tasks =
          user.tasks
          |> Enum.reduce(%{}, fn task, acc ->
            task = Repo.preload(task, time_tracks: query)

            [range_end_date, range_start_date] =
              if(Enum.empty?(task.time_tracks)) do
                range_end_date = smaller_date(DateTime.to_date(task.end_datetime), end_date)
                range_start_date = greater_date(DateTime.to_date(task.start_datetime), start_date)
                [range_end_date, range_start_date]
              else
                first_time_track = task.time_tracks |> List.last()
                last_time_track = task.time_tracks |> List.first()

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
              case Enum.member?(Date.range(start_date, end_date), date) do
                true ->
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
                      Date.diff(task.start_datetime, date) === 0 or Enum.empty?(task.time_tracks) or
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

                    time_track =
                      if date_formatted_time_tracks != %{} do
                        extract_time_track(task)
                      end

                    [time_track_status, time_track] =
                      case time_track do
                        nil -> [false, nil]
                        _ -> [true, time_track]
                      end

                    duration = sec_to_str(duration)

                    task =
                      Map.put_new(task, :duration, duration)
                      |> Map.put_new(:time_track_status, time_track_status)
                      |> Map.put_new(:time_track, time_track)

                    tasks = Map.get(date_acc, Date.to_iso8601(date)) ++ [task]
                    Map.put(date_acc, Date.to_iso8601(date), tasks)
                  else
                    date_acc
                  end

                false ->
                  date_acc
              end
            end)
          end)

        Map.put(user, :tasks, date_formatted_tasks)
      end)

    render(conn, "user_tasks_index.json", users: users)
  end

  def project_tasks(conn, %{"workspace_id" => workspace_id}) do
    tasks = TaskModel.list_workspace_tasks(workspace_id) |> Repo.preload([:owner, :members])
    render(conn, "index.json", tasks: tasks)
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

  defp map_to_atom(params) do
    for {key, value} <- params, into: %{}, do: {String.to_atom(key), value}
  end

  defp date_wise_orientation(task_list) do
    Enum.reduce(task_list, %{}, fn time_track, acc ->
      case Map.has_key?(acc, Date.to_iso8601(time_track.start_time)) do
        true ->
          time_track_add = Map.get(acc, Date.to_iso8601(time_track.start_time)) ++ [time_track]
          Map.replace!(acc, Date.to_iso8601(time_track.start_time), time_track_add)

        false ->
          acc = Map.put_new(acc, Date.to_iso8601(time_track.start_time), [])
          time_track_new = Map.get(acc, Date.to_iso8601(time_track.start_time)) ++ [time_track]
          Map.replace!(acc, Date.to_iso8601(time_track.start_time), time_track_new)
      end
    end)
  end

  defp calculate_durations(task_list) when is_nil(task_list) == false do
    Enum.reduce(task_list, 0, fn time_track, acc ->
      case is_nil(time_track.duration) do
        true -> acc
        false -> acc + time_track.duration
      end
    end)
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

  defp select_dates(start_date, frequency) do
    {:ok, start_date} =
      start_date
      |> Date.from_iso8601()

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

    {start_date, end_date}
  end

  defp get_project_ids(query_params) do
    case is_nil(String.first(query_params["project_ids"])) do
      true ->
        []

      false ->
        project_ids =
          Enum.map(String.split(query_params["project_ids"], ","), fn x ->
            String.to_integer(x)
          end)

        [0 | project_ids]
    end
  end

  defp create_query(project_ids, workspace_id, start_date, end_date) do
    from task in Task,
      join: project in Project,
      on: task.project_id == project.id or task.project_id in ^project_ids,
      left_join: time_track in TimeTracking,
      on: time_track.task_id == task.id,
      where:
        project.workspace_id == ^workspace_id and
          (fragment("?::date BETWEEN ? AND ?", task.start_datetime, ^start_date, ^end_date) or
             fragment("?::date BETWEEN ? AND ?", task.end_datetime, ^start_date, ^end_date) or
             fragment(
               "?::date <= ? AND ?::date >= ?",
               task.start_datetime,
               ^start_date,
               task.end_datetime,
               ^end_date
             ) or
             fragment(
               "?::date BETWEEN ? AND ?",
               time_track.start_time,
               ^start_date,
               ^end_date
             ) or
             fragment(
               "?::date BETWEEN ? AND ?",
               time_track.end_time,
               ^start_date,
               ^end_date
             ) or
             fragment(
               "?::date <= ? AND ?::date >= ?",
               time_track.start_time,
               ^start_date,
               time_track.end_time,
               ^end_date
             ))
  end

  defp get_users(query_params, query, workspace_id) do
    user_ids =
      case is_nil(String.first(query_params.user_id)) do
        true ->
          [0]

        false ->
          user_ids =
            Enum.map(String.split(query_params.user_id, ","), fn x -> String.to_integer(x) end)

          [0 | user_ids]
      end

    UserModel.list_users(workspace_id, user_ids)
    |> Repo.preload(tasks: {query, :project})
  end

  defp extract_time_track(task) do
    query =
      from time_tracking in TimeTracking,
        where: time_tracking.task_id == ^task.id and time_tracking.status == "running"

    List.first(Repo.all(query))
  end
end
