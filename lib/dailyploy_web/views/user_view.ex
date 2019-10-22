defmodule DailyployWeb.UserView do
  use DailyployWeb, :view
  alias DailyployWeb.UserView
  alias DailyployWeb.TaskView
  alias DailyployWeb.ErrorHelpers

  def render("index.json", %{users: users}) do
    %{users: render_many(users, UserView, "user.json")}
  end

  def render("user_tasks_index.json", %{users: users}) do
    %{users: render_many(users, UserView, "user_tasks.json")}
  end

  def render("show.json", %{user: user}) do
    %{user: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, name: user.name, email: user.email}
  end

  def render("user.json", %{user: user, workspace: workspace}) do
    case workspace do
      nil -> %{id: user.id, name: user.name, email: user.email, workspace_id: nil}
      _ -> %{id: user.id, name: user.name, email: user.email, workspace_id: workspace.id}
    end
  end

  def render("user_tasks.json", %{user: user}) do
    %{id: user.id, name: user.name, email: user.email, tasks: render_many(user.tasks, TaskView, "task_with_project.json")}
  end

  def render("access_token.json", %{access_token: access_token}) do
    %{access_token: access_token}
  end

  def render("signup_error.json", %{user: user}) do
    %{errors: ErrorHelpers.changeset_error_to_map(user.errors)}
  end

  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end
end
