defmodule DailyployWeb.TaskView do
  use DailyployWeb, :view
  alias DailyployWeb.TaskView
  alias DailyployWeb.UserView
  alias DailyployWeb.ProjectView
  alias DailyployWeb.TaskCategoryView
  alias DailyployWeb.TimeTrackingView
  alias DailyployWeb.TaskCommentView
  alias DailyployWeb.TaskStatusView
  alias DailyployWeb.ErrorHelpers
  alias Dailyploy.Repo

  def render("index.json", %{tasks: tasks}) do
    %{tasks: render_many(tasks, TaskView, "task_with_user.json")}
  end

  def render("index_with_project.json", %{tasks: tasks}) do
    %{tasks: render_many(tasks, TaskView, "task_with_project.json")}
  end

  def render("show.json", %{task: task}) do
    %{task: render_one(task, TaskView, "task_with_user.json")}
  end

  def render("task.json", %{task: task}) do
    %{
      id: task.id,
      name: task.name,
      identifier: task.identifier || "",
      estimation: task.estimation,
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      is_complete: task.is_complete,
      comments: task.comments
    }
  end

  def render("task_running_call.json", %{task: task}) do
    task = task |> Repo.preload([:task_status])

    %{
      id: task.id,
      name: task.name,
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      comments: task.comments,
      status: render_one(task.task_status, TaskStatusView, "status.json"),
      priority: task.priority,
      estimation: task.estimation,
      is_complete: task.is_complete,
      members: render_many(task.members, UserView, "user.json"),
      owner: render_one(task.owner, UserView, "user.json"),
      category: render_one(task.category, TaskCategoryView, "task_category.json"),
      time_tracked: render_many(task.time_tracks, TimeTrackingView, "task_with_track_time.json")
    }
  end

  def render("task_comments.json", %{task: task}) do
    task = task |> Repo.preload([:task_status])

    %{
      id: task.id,
      name: task.name,
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      estimation: task.estimation,
      is_complete: task.is_complete,
      comments: task.comments,
      status: render_one(task.task_status, TaskStatusView, "status.json"),
      priority: task.priority
    }
  end

  def render("deleted_task.json", %{task: task}) do
    task = task |> Repo.preload([:task_status])

    %{
      id: task.id,
      name: task.name,
      estimation: task.estimation,
      is_complete: task.is_complete,
      status: render_one(task.task_status, TaskStatusView, "status.json"),
      priority: task.priority,
      owner: render_one(task.owner, UserView, "user.json")
    }
  end

  def render("task_running.json", %{time_track: time_track}) do
    %{
      id: time_track.id,
      task_id: time_track.task_id,
      start_datetime: time_track.start_time,
      status: time_track.status,
      time_log: time_track.time_log,
      task: render_one(time_track.task, TaskView, "task_running_call.json")
    }
  end

  def render("task_with_user.json", %{task: task}) do
    task = Repo.preload(task, :task_status)

    %{
      id: task.id,
      name: task.name,
      identifier: task.identifier || "",
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      estimation: task.estimation,
      is_complete: task.is_complete,
      comments: task.comments,
      status: render_one(task.task_status, TaskStatusView, "status.json"),
      priority: task.priority,
      members: render_many(task.members, UserView, "user.json"),
      owner: render_one(task.owner, UserView, "user.json"),
      category: render_one(task.category, TaskCategoryView, "task_category.json"),
      time_tracked: render_many(task.time_tracks, TimeTrackingView, "task_with_track_time.json"),
      date_formatted_time_tracks:
        render_many(
          task.date_formatted_time_tracks,
          TimeTrackingView,
          "date_formatted_time_tracks.json"
        )
    }
  end

  def render("task_with_user_show.json", %{task: task}) do
    task = task |> Repo.preload([:task_status])

    %{
      id: task.id,
      name: task.name,
      identifier: task.identifier || "",
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      comments: task.comments,
      estimation: task.estimation,
      is_complete: task.is_complete,
      status: render_one(task.task_status, TaskStatusView, "status.json"),
      priority: task.priority,
      members: render_many(task.members, UserView, "user.json"),
      owner: render_one(task.owner, UserView, "user.json"),
      category: render_one(task.category, TaskCategoryView, "task_category.json"),
      project: render_one(task.project, ProjectView, "project_show.json"),
      task_comments: render_many(task.task_comments, TaskCommentView, "task_comments.json"),
      time_tracked: render_many(task.time_tracks, TimeTrackingView, "task_with_track_time.json"),
      date_formatted_time_tracks:
        render_many(
          task.date_formatted_time_tracks,
          TimeTrackingView,
          "date_formatted_time_tracks.json"
        )
    }
  end

  def render("task_with_project.json", %{task: task}) do
    task = task |> Repo.preload([:task_status])

    %{
      id: task.id,
      name: task.name,
      identifier: task.identifier || "",
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      estimation: task.estimation,
      is_complete: task.is_complete,
      comments: task.comments,
      status: render_one(task.task_status, TaskStatusView, "status.json"),
      priority: task.priority,
      duration: task.duration,
      project: render_one(task.project, ProjectView, "project.json"),
      created_at: task.inserted_at,
      date_formatted_time_tracks:
        render_many(
          task.date_formatted_time_tracks,
          TimeTrackingView,
          "date_formatted_time_tracks.json"
        ),
      time_tracked: render_many(task.time_tracks, TimeTrackingView, "task_with_track_time.json")
    }
  end

  def render("user_tasks.json", %{task: task}) do
    task = task |> Repo.preload([:task_status])

    %{
      id: task.id,
      name: task.name,
      identifier: task.identifier || "",
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      estimation: task.estimation,
      is_complete: task.is_complete,
      status: render_one(task.task_status, TaskStatusView, "status.json"),
      priority: task.priority,
      duration: task.duration,
      time_track_status: task.time_track_status,
      time_track: render_one(task.time_track, TaskView, "task_running.json"),
      project: render_one(task.project, ProjectView, "project_user_task.json"),
      time_tracked: render_many(task.time_tracks, TimeTrackingView, "task_with_track_time.json")
    }
  end

  def render("task_running.json", %{task: task}) do
    if task != nil do
      %{
        id: task.id,
        start_time: task.start_time,
        status: task.status,
        task_id: task.task_id
      }
    else
      %{
        time_track: nil
      }
    end
  end

  def render("task_with_user_and_project.json", %{task: task}) do
    task = task |> Repo.preload([:task_status])

    %{
      id: task.id,
      name: task.name,
      identifier: task.identifier || "",
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      comments: task.comments,
      estimation: task.estimation,
      is_complete: task.is_complete,
      status: render_one(task.task_status, TaskStatusView, "status.json"),
      priority: task.priority,
      duration: task.duration,
      duration_in_string: task.duration_in_string,
      category: render_one(task.category, TaskCategoryView, "task_category.json"),
      project: render_one(task.project, ProjectView, "project_for_report.json"),
      time_tracked: render_many(task.time_tracks, TimeTrackingView, "task_with_track_time.json"),
      created_at: task.inserted_at,
      date_formatted_time_tracks:
        render_many(
          task.date_formatted_time_tracks,
          TimeTrackingView,
          "date_formatted_time_tracks.json"
        )
    }
  end

  def render("date_formatted_user_tasks.json", %{task: {date, tasks}}) do
    %{
      date: date,
      tasks: render_many(tasks, TaskView, "user_tasks.json")
    }
  end

  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end
end
