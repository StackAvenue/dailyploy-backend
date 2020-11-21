defmodule Dailyploy.Model.Analysis do
  alias Dailyploy.Repo
  import Ecto.Query

  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.TaskListTasks
  alias Dailyploy.Schema.TaskLists
  alias Dailyploy.Schema.UserProject
  alias Dailyploy.Schema.TimeTracking

  def get_all_tasks(project_id, start_date, end_date) do
    dashboard_tasks = get_dashboard_tasks(project_id, start_date, end_date)
    roadmap_tasks = get_roadmap_tasks(project_id, start_date, end_date)

    total_time_spent =
      Enum.map(dashboard_tasks, fn x -> x.time_tracks end)
      |> Enum.concat()
      |> Enum.reduce(0, fn y, acc -> acc + y.duration end)
      |> div(3600)

    total_task_count =
      Enum.count(dashboard_tasks) + Enum.count(roadmap_tasks, fn task -> task.task_id == nil end)

    completed_tasks = Enum.count(dashboard_tasks, fn task -> task.is_complete == true end)

    %{
      "completed_tasks" => completed_tasks,
      "total_tasks" => total_task_count,
      "total_time_spent" => total_time_spent
    }
  end

  def get_all_members(project_id) do
    query =
      from projectuser in UserProject,
        where: projectuser.project_id == ^project_id,
        select: projectuser

    Repo.all(query) |> Enum.count()
  end

  def get_budget(project_id, start_date, end_date) do
    project_query =
      from project in Project,
        where: project.id == ^project_id,
        select: project.monthly_budget

    project_budget = Repo.one(project_query)

    dashboard_tasks = get_dashboard_tasks(project_id, start_date, end_date)

    preloaded_data =
      dashboard_tasks
      |> Repo.preload([:project, owner: [:user_workspace_settings]])

    user_tasks = Enum.group_by(preloaded_data, fn x -> x.owner_id end)

    member_time =
      Enum.map(user_tasks, fn {x, y} ->
        {x,
         y
         |> Enum.map(fn x -> x.time_tracks end)
         |> Enum.concat()
         |> Enum.reduce(0, fn y, acc -> acc + y.duration end)}
      end)
      |> Enum.map(fn {x, y} -> {x, y / 3600} end)

    user_details =
      Enum.map(user_tasks, fn {x, y} ->
        {x, y |> Enum.map(fn x -> x.owner end) |> List.first()}
      end)
      |> Enum.map(fn {x, y} ->
        {x, y.user_workspace_settings |> Enum.map(fn x -> x.hourly_expense end) |> List.first()}
      end)

    member_expense_total =
      Enum.concat(member_time, user_details)
      |> Enum.group_by(fn {x, y} -> x end)
      |> Enum.map(fn {key, value} -> {key, value |> Enum.map(fn {x, y} -> y end)} end)
      |> Enum.map(fn {_, y} -> y |> Enum.reduce(fn x, acc -> x * acc end) end)
      |> Enum.sum()

    case member_expense_total < project_budget and project_budget > 0 do
      false ->
        0

      true ->
        (project_budget - member_expense_total) / project_budget * 100
    end
  end

  def get_top_5_members(project_id, start_date, end_date) do
    query =
      from task in Task,
      join: time_tracks in TimeTracking,
      on: task.id == time_tracks.task_id,
      where: task.project_id == ^project_id and 
            task.is_complete == true and 
            time_tracks.start_time > ^start_date and
            time_tracks.start_time < ^end_date,
      distinct: true,
      select: task

    dashboard_tasks =
      Repo.all(query) |> Repo.preload([:time_tracks, owner: [:user_workspace_settings]])

    group_by_user_data = Enum.group_by(dashboard_tasks, fn x -> x.owner_id end)

    high_priority_task_count =
      Enum.map(group_by_user_data, fn {x, y} ->
        %{
          "user_id" => x,
          "velocity" =>
            y
            |> Enum.map(fn task ->
              case task.priority do
                "low" -> 1
                "medium" -> 2
                "high" -> 3
              end
            end)
            |> Enum.sum()
        }
      end)

    task_count =
      Enum.map(group_by_user_data, fn {x, y} ->
        %{"user_id" => x, "task_count" => y |> Enum.count()}
      end)

    priority_count = top_members(group_by_user_data, high_priority_task_count, "velocity")
    task_count = top_members(group_by_user_data, task_count, "task_count")

    %{"priority_count" => priority_count, "task_count" => task_count}
  end

  defp top_members(group_by_user_data, task_count, x) do
    member_time =
      Enum.map(group_by_user_data, fn {x, y} ->
        %{
          "user_id" => x,
          "total_time" =>
            y
            |> Enum.map(fn x -> x.time_tracks end)
            |> Enum.concat()
            |> Enum.reduce(0, fn y, acc -> acc + y.duration end)
            |> div(3600)
        }
      end)

    user_details =
      Enum.map(group_by_user_data, fn {x, y} ->
        {x, y |> Enum.map(fn x -> x.owner end) |> List.first()}
      end)
      |> Enum.map(fn {x, y} ->
        %{
          "user_id" => x,
          "name" => y.name,
          "profile_photo" => y.provider_img,
          "expense" =>
            y.user_workspace_settings |> Enum.map(fn x -> x.hourly_expense end) |> List.first()
        }
      end)

    top_five_members =
      Enum.concat(task_count, member_time)
      |> Enum.concat(user_details)
      |> Enum.reduce(%{}, fn a, acc ->
        acc =
          case Map.has_key?(acc, a["user_id"]) do
            true ->
              temp = Map.merge(acc[a["user_id"]], a)
              Map.replace(acc, a["user_id"], temp)

            false ->
              Map.put_new(acc, a["user_id"], a)
          end
      end)
      |> Enum.to_list()
      |> Enum.sort(fn {key1, value1}, {key2, value2} -> value1[x] > value2[x] end)
      |> Enum.map(fn {key, value} -> value end)
  end

  def get_weekly_data(project_id, start_date, end_date) do
    dashboard_tasks = get_dashboard_tasks(project_id, start_date, end_date)
    roadmap_tasks = get_roadmap_tasks(project_id, start_date, end_date)

    total_task_count =
      Enum.count(dashboard_tasks) + Enum.count(roadmap_tasks, fn task -> task.task_id == nil end)
    
      query =
        from task in Task,
        join: time_tracks in TimeTracking,
        on: task.id == time_tracks.task_id,
        where: task.project_id == ^project_id and 
              task.is_complete == true and
              time_tracks.start_time > ^start_date and
              time_tracks.start_time < ^end_date,
        group_by: fragment("weekData"),
        select: [
          fragment("date_trunc('week',?) as weekData", time_tracks.start_time),
          fragment("COUNT(DISTINCT(?))", task.id)
        ]

      week_by_completed_task = Repo.all(query)
      query =
        from task in Task,
        join: time_tracks in TimeTracking,
        on: task.id == time_tracks.task_id,
        where: task.project_id == ^project_id and 
              time_tracks.start_time > ^start_date and
              time_tracks.start_time < ^end_date,
        group_by: fragment("weekData"),
        select: [
          fragment("date_trunc('week',?) as weekData", time_tracks.start_time),
          fragment("COUNT(DISTINCT(?))", task.id)
        ]

    week_by_total_task = Repo.all(query)
    %{weekly_completed_tasks: week_by_completed_task, 
    total_weekly_tasks: week_by_total_task,
    total_tasks: total_task_count}
  end

  def get_roadmap_status(project_id, start_date, end_date) do
    query =
      from task_list in TaskLists,
        where:
          task_list.project_id == ^project_id and
            task_list.updated_at > ^start_date and
            task_list.updated_at < ^end_date,
        order_by: task_list.inserted_at,
        select: task_list

    task_lists = Repo.all(query) |> Repo.preload(:checklists)

    planned_task_lists =
      Enum.filter(task_lists, fn x -> x.status == "Planned" end)
      |> List.first()

    planned =
      case planned_task_lists do
        nil ->
          "No Roadmap Planned"

        _ ->
          planned_map = Map.from_struct(planned_task_lists)

          %{
            "id" => Map.get(planned_map, :id),
            "name" => Map.get(planned_map, :name),
            "start_date" => Map.get(planned_map, :start_date),
            "end_date" => Map.get(planned_map, :end_date)
          }
      end

    completed_task_lists =
      Enum.filter(task_lists, fn task_list -> task_list.status == "Completed" end)
      |> List.last()

    completed =
      case completed_task_lists do
        nil ->
          "No Roadmap Completed"

        _ ->
          completed_map = Map.from_struct(completed_task_lists)
          checklists = Map.get(completed_map, :checklists)
          total_checklists = Enum.map(checklists, fn x -> x end) |> Enum.count()

          complete_checklists =
            Enum.filter(checklists, fn x -> x.is_completed == true end) |> Enum.count()

          progress =
            case total_checklists > 0 do
              true ->
                complete_checklists / total_checklists * 100

              false ->
                0
            end

          %{
            "id" => Map.get(completed_map, :id),
            "name" => Map.get(completed_map, :name),
            "progress" => progress,
            "start_date" => Map.get(completed_map, :start_date),
            "end_date" => Map.get(completed_map, :end_date)
          }
      end

    running_task_lists = Enum.filter(task_lists, fn x -> x.status == "Running" end)

    running =
      Enum.map(running_task_lists, fn task_list ->
        {task_list.id, task_list.name, task_list.start_date, task_list.end_date,
         task_list.checklists |> Enum.count(),
         task_list.checklists
         |> Enum.filter(fn task_list -> task_list.is_completed == true end)
         |> Enum.count()}
      end)
      |> Enum.map(fn {id, name, start_date, end_date, total, completed} ->
        case total > 0 do
          true ->
            %{
              "id" => id,
              "name" => name,
              "progress" => completed / total * 100,
              "start_date" => start_date,
              "end_date" => end_date
            }

          false ->
            %{
              "id" => id,
              "name" => name,
              "progress" => 0,
              "start_date" => start_date,
              "end_date" => end_date
            }
        end
      end)

    %{"planned" => planned, "completed" => completed, "running" => running}
  end

  defp get_dashboard_tasks(project_id, start_date, end_date) do 
    query =
      from task in Task,
      join: time_tracks in TimeTracking,
      on: task.id == time_tracks.task_id,
      where: task.project_id == ^project_id and 
             time_tracks.start_time > ^start_date and
             time_tracks.start_time < ^end_date,
      distinct: true,
      select: task
      

    Repo.all(query) |> Repo.preload(:time_tracks)
  end

  defp get_roadmap_tasks(project_id, start_date, end_date) do
    query =
      from tasklist in TaskLists,
        where: tasklist.project_id == ^project_id,
        select: tasklist

    task_lists = Repo.all(query) |> Repo.preload(:user_stories)

    task_list_ids = Enum.map(task_lists, fn task_list -> task_list.id end)

    userstory_ids =
      Enum.map(task_lists, fn task_list ->
        task_list.user_stories |> Enum.map(fn item -> item.id end)
      end)

    userstories_ids = Enum.concat(userstory_ids)

    preload_query_1 = tlt_query(task_list_ids, start_date, end_date)
    preload_query_2 = userstory_query(userstories_ids, start_date, end_date)

    preloaded_tasks =
      task_lists
      |> Repo.preload(
        task_list_tasks: preload_query_1,
        user_stories: [task_lists_tasks: preload_query_2]
      )

    roadmap_tasks =
      Enum.map(preloaded_tasks, fn task_list -> task_list.task_list_tasks end)
      |> Enum.concat()
      |> Enum.filter(fn task -> task.task_id == nil end)

    userstory_tasks =
      Enum.map(preloaded_tasks, fn task_list -> task_list.user_stories end)
      |> Enum.concat()
      |> Enum.map(fn user_story -> user_story.task_lists_tasks end)
      |> Enum.concat()
      |> Enum.filter(fn task -> task.task_id == nil end)

    Enum.concat(roadmap_tasks, userstory_tasks)
  end

  defp tlt_query(task_list_ids, start_date, end_date) do
    query =
      from task in TaskListTasks,
        where:
          task.task_lists_id in ^task_list_ids and task.updated_at > ^start_date and
            task.updated_at < ^end_date,
        select: task
  end

  defp userstory_query(userstories_ids, start_date, end_date) do
    query =
      from task in TaskListTasks,
        where:
          task.user_stories_id in ^userstories_ids and task.updated_at > ^start_date and
            task.updated_at < ^end_date,
        select: task
  end

  defp calculate_total_time(time_tracks) do
    Enum.map(time_tracks, fn x -> x end) 
  end
end
