defmodule DailyployWeb.UserStoriesView do
  use DailyployWeb, :view

  alias DailyployWeb.{
    UserView,
    TaskStatusView,
    TaskListTasksView,
    UserStoriesView,
    RoadmapChecklistView
  }

  alias Dailyploy.Repo

  def render("show.json", %{user_stories: user_stories}) do
    %{
      id: user_stories.id,
      name: user_stories.name,
      description: user_stories.description,
      is_completed: user_stories.is_completed,
      owner_id: user_stories.owner_id,
      priority: user_stories.priority,
      due_date: user_stories.due_date,
      task_status: render_one(user_stories.task_status, TaskStatusView, "status.json"),
      owner: render_one(user_stories.owner, UserView, "user.json"),
      task_lists_id: user_stories.task_lists_id
    }
  end

  def render("delete.json", %{user_stories: user_stories}) do
    %{
      id: user_stories.id,
      name: user_stories.name,
      description: user_stories.description,
      is_completed: user_stories.is_completed,
      owner_id: user_stories.owner_id,
      priority: user_stories.priority,
      due_date: user_stories.due_date,
      task_lists_id: user_stories.task_lists_id
    }
  end

  def render("task_list_view.json", %{user_stories: user_stories}) do
    %{
      id: user_stories.id,
      name: user_stories.name,
      description: user_stories.description,
      is_completed: user_stories.is_completed,
      owner_id: user_stories.owner_id,
      priority: user_stories.priority,
      due_date: user_stories.due_date,
      task_status: render_one(user_stories.task_status, TaskStatusView, "status.json"),
      owner: render_one(user_stories.owner, UserView, "user.json"),
      roadmap_id: user_stories.task_lists_id,
      task_lists: render_many(user_stories.task_lists_tasks, TaskListTasksView, "user_show.json"),
      checklist:
        render_many(user_stories.roadmap_checklist, RoadmapChecklistView, "user_show.json")
    }
  end

  def render("user_show.json", %{user_stories: user_stories}) do
    %{
      id: user_stories.id,
      name: user_stories.name,
      description: user_stories.description,
      is_completed: user_stories.is_completed,
      owner_id: user_stories.owner_id,
      priority: user_stories.priority,
      due_date: user_stories.due_date,
      attachments: render_many(user_stories.attachments, UserStoriesView, "url.json"),
      task_status: render_one(user_stories.task_status, TaskStatusView, "status.json"),
      owner: render_one(user_stories.owner, UserView, "user.json"),
      roadmap_id: user_stories.task_lists_id,
      task_lists: render_many(user_stories.task_lists_tasks, TaskListTasksView, "user_show.json"),
      checklist:
        render_many(user_stories.roadmap_checklist, RoadmapChecklistView, "user_show.json"),
      comments: render_many(user_stories.comments, UserStoriesView, "comment.json")
    }
  end

  def render("comment.json", %{user_stories: tlt}) do
    tlt = Repo.preload(tlt, [:attachment, :user])

    %{
      comment: tlt.comments,
      attachments: render_many(tlt.attachment, UserStoriesView, "attachment.json"),
      user: tlt.user.id,
      id: tlt.id,
      user_name: tlt.user.name
    }
  end

  def render("attachment.json", %{user_stories: attachment}) do
    user_story = Dailyploy.Repo.preload(attachment, [:attachments])

    %{
      attachments: render_many(user_story.attachments, UserStoriesView, "url.json")
    }
  end

  def render("url.json", %{user_stories: params}) do
    %{
      id: params.id,
      image_url: params.image_url
    }
  end
end
