defmodule DailyployWeb.TaskView do
  use DailyployWeb, :view
  alias DailyployWeb.TaskView
  alias DailyployWeb.UserView
  alias DailyployWeb.ProjectView
  alias DailyployWeb.TaskCategoryView
  alias DailyployWeb.TimeTrackingView
  alias DailyployWeb.ErrorHelpers

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
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      comments: task.comments
    }
  end

  def render("deleted_task.json", %{task: task}) do
    %{
      id: task.id,
      name: task.name,
      status: task.status,
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
      task: render_one(time_track.task, TaskView, "task.json")
    }
  end

  def render("task_with_user.json", %{task: task}) do
    %{
      id: task.id,
      name: task.name,
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      comments: task.comments,
      status: task.status,
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

  def render("task_with_project.json", %{task: task}) do
    %{
      id: task.id,
      name: task.name,
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      comments: task.comments,
      status: task.status,
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

  def render("task_with_user_and_project.json", %{task: task}) do
    %{
      id: task.id,
      name: task.name,
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      comments: task.comments,
      status: task.status,
      priority: task.priority,
      duration: task.duration,
      duration_in_string: task.duration_in_string,
      owner: render_one(task.owner, UserView, "user.json"),
      category: render_one(task.category, TaskCategoryView, "task_category.json"),
      project: render_one(task.project, ProjectView, "project_for_listing.json"),
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
      tasks: render_many(tasks, TaskView, "task_with_project.json")
    }
  end

  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end
end
