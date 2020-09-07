defmodule DailyployWeb.MilestoneView do
  use DailyployWeb, :view
  alias DailyployWeb.MilestoneView

  def render("show.json", %{milestones: milestones}) do
    %{milestone: render_many(milestones, MilestoneView, "milestone.json")}
  end

  def render("milestone.json", %{milestone: milestone}) do
    %{
      id: milestone.id,
      status: milestone.status,
      name: milestone.name,
      description: milestone.description,
      due_date: milestone.due_date,
      project_id: milestone.project_id
    }
  end
end
