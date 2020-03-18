defmodule DailyployWeb.ProjectView do
  use DailyployWeb, :view
  alias DailyployWeb.ProjectView
  alias DailyployWeb.UserView
  alias DailyployWeb.ContactView
  alias DailyployWeb.ErrorHelpers

  def render("index.json", %{projects: projects}) do
    %{projects: render_many(projects, ProjectView, "project_for_listing.json")}
  end

  def render("show_create.json", %{project: project}) do
    %{project: render_one(project, ProjectView, "project_create.json")}
  end

  def render("show.json", %{project: project}) do
    %{project: render_one(project, ProjectView, "project.json")}
  end

  def render("show_project.json", %{project: project}) do
    %{
      id: project.id,
      name: project.name,
      start_date: project.start_date,
      end_date: project.end_date,
      description: project.description,
      color_code: project.color_code
    }
  end

  def render("project_create.json", %{project: project}) do
    %{
      id: project.id,
      name: project.name,
      start_date: project.start_date,
      end_date: project.end_date,
      description: project.description,
      color_code: project.color_code,
      created_at: project.inserted_at,
      contacts: render_many(project.contacts, ContactView, "contact.json"),
      members: render_many(project.members, UserView, "user.json")
    }
  end

  def render("project.json", %{project: project}) do
    %{
      id: project.id,
      name: project.name,
      start_date: project.start_date,
      end_date: project.end_date,
      description: project.description,
      color_code: project.color_code,
      created_at: project.inserted_at,
      members: render_many(project.members, UserView, "user.json")
    }
  end

  def render("project_show.json", %{project: project}) do
    %{
      id: project.id,
      name: project.name,
      start_date: project.start_date,
      end_date: project.end_date,
      description: project.description,
      color_code: project.color_code,
      contacts: render_many(project.contacts, ContactView, "contact.json"),
      created_at: project.inserted_at
    }
  end

  def render("project_for_listing.json", %{project: project}) do
    %{
      id: project.id,
      name: project.name,
      start_date: project.start_date,
      end_date: project.end_date,
      description: project.description,
      color_code: project.color_code,
      created_at: project.inserted_at,
      members: render_many(project.members, UserView, "user.json"),
      owner: render_one(project.owner, UserView, "user.json")
    }
  end

  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end

  def render("error_in_deletion.json", %{}) do
    %{errors: "Error in Deleting Project"}
  end
end
