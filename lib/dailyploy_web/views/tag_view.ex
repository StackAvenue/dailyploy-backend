defmodule DailyployWeb.TagView do
  use DailyployWeb, :view
  alias DailyployWeb.TagView
  alias DailyployWeb.ErrorHelpers

  def render("index.json", %{tags: tags}) do
    %{tasks: render_many(tags, TagView, "tag.json")}
  end

  def render("show.json", %{tag: tag}) do
    %{task: render_one(tag, TagView, "tag.json")}
  end

  def render("tag.json", %{tag: tag}) do
    %{id: tag.id, name: tag.name, color: tag.color}
  end

  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end

  def render("error_in_deletion.json", %{}) do
    %{errors: "Error in Deleting Tag"}
  end
end
