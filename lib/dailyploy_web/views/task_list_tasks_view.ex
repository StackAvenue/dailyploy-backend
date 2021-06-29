defmodule DailyployWeb.TaskListTasksView do
  use DailyployWeb, :view
  # alias DailyployWeb.ProjectTaskListView
  alias DailyployWeb.{
    UserView,
    TaskListTasksView,
    TaskListsView,
    TaskCategoryView,
    TaskStatusView,
    RoadmapChecklistView
  }

  alias Dailyploy.Repo

  def render("show.json", %{task_list_tasks: task_list_tasks}) do
    task =
      case task_list_tasks.task_id do
        nil ->
          nil

        _ ->
          tlt = task_list_tasks |> Repo.preload([:task])
          tlt.task
      end

    task_list_tasks = Map.put_new(task_list_tasks, :task, task)

    tracked_time =
      case task_list_tasks.task_id do
        nil -> 0
        _ -> calculate_track_time(task_list_tasks)
      end

    %{
      id: task_list_tasks.id,
      name: task_list_tasks.name,
      identifier: task_list_tasks.identifier,
      # task: render_one(task_list_tasks.task, TaskListTasksView, "task.json"),
      description: task_list_tasks.description,
      task_id: task_list_tasks.task_id,
      estimation: task_list_tasks.estimation,
      tracked_time: tracked_time,
      status: task_list_tasks.status,
      priority: task_list_tasks.priority,
      owner_id: task_list_tasks.owner_id,
      task_status: render_one(task_list_tasks.task_status, TaskStatusView, "status.json"),
      category_id: task_list_tasks.category_id,
      task_lists_id: task_list_tasks.task_lists_id,
      comments: render_many(task_list_tasks.comments, TaskListTasksView, "comment.json"),
      owner: render_one(task_list_tasks.owner, UserView, "user.json"),
      checklist: render_many(task_list_tasks.checklist, RoadmapChecklistView, "user_show.json"),
      category: render_one(task_list_tasks.category, TaskCategoryView, "task_category.json"),
      task_lists: render_one(task_list_tasks.task_lists, TaskListsView, "show_project_list.json")
    }
  end

  def render("comment.json", %{task_list_tasks: tlt}) do
    tlt = Repo.preload(tlt, [:attachment, :user])

    %{
      comment: tlt.comments,
      attachments: render_many(tlt.attachment, TaskListTasksView, "attachment.json"),
      user: tlt.user.id,
      id: tlt.id,
      user_name: tlt.user.name
    }
  end

  def render("attachment.json", %{task_list_tasks: tlt}) do
    %{
      url: tlt.image_url
    }
  end

  def render("task.json", %{task_list_tasks: tlt}) do
    %{
      id: tlt.id,
      name: tlt.name,
      start_datetime: tlt.start_datetime,
      end_datetime: tlt.end_datetime,
      estimation: tlt.estimation,
      is_complete: tlt.is_complete,
      comments: tlt.comments,
      priority: tlt.priority
    }
  end

  defp calculate_track_time(tlt) do
    tlt = Repo.preload(tlt, task: :time_tracks)

    Enum.reduce(tlt.task.time_tracks, 0, fn track, acc ->
      acc + track.duration
    end)
  end

  def render("user_show.json", %{task_list_tasks: task_list_tasks}) do
    task_list_tasks =
      task_list_tasks
      |> Dailyploy.Repo.preload([
        :owner,
        :category,
        :task_lists,
        :task_status,
        :checklist,
        :comments
      ])

    %{
      id: task_list_tasks.id,
      name: task_list_tasks.name,
      description: task_list_tasks.description,
      task_id: task_list_tasks.task_id,
      estimation: task_list_tasks.estimation,
      status: task_list_tasks.status,
      priority: task_list_tasks.priority,
      comments: render_many(task_list_tasks.comments, TaskListTasksView, "comment.json"),
      owner_id: task_list_tasks.owner_id,
      task_status: render_one(task_list_tasks.task_status, TaskStatusView, "status.json"),
      category_id: task_list_tasks.category_id,
      task_lists_id: task_list_tasks.task_lists_id,
      owner: render_one(task_list_tasks.owner, UserView, "user.json"),
      checklist: render_many(task_list_tasks.checklist, RoadmapChecklistView, "user_show.json"),
      category: render_one(task_list_tasks.category, TaskCategoryView, "task_category.json"),
      task_lists: render_one(task_list_tasks.task_lists, TaskListsView, "show_project_list.json")
    }
  end

  def render("index.json", %{task_lists: task_lists}) do
    %{
      entries: render_many(task_lists.entries, TaskListTasksView, "show.json"),
      page_number: task_lists.page_number,
      page_size: task_lists.page_size,
      total_entries: task_lists.total_entries,
      total_pages: task_lists.total_pages
    }
  end
end
