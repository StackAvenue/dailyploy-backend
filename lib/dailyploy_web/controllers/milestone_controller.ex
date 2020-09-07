defmodule DailyployWeb.MilestoneController do
  use DailyployWeb, :controller
  import Plug.Conn

  alias Dailyploy.Schema.Milestone
  alias Dailyploy.Model.Milestone, as: MilestoneModel

  plug Auth.Pipeline

  def index(conn, %{
        "project_id" => project_id,
        "start_date" => start_date,
        "end_date" => end_date
      }) do
    milestones = MilestoneModel.get_milestones(project_id, start_date, end_date)
    render(conn, "show.json", milestones: milestones)
  end

  def create(conn, %{"project_id" => project_id, "milestone" => milestone} = params) do
    case conn.status do
      404 ->
        conn
        |> send_resp(404, "not_found")

      nil ->
        milestone =
          milestone
          |> Map.put_new("project_id", project_id)

        case MilestoneModel.create_milestone(milestone) do
          {:ok, %Milestone{} = milestone} ->
            conn
            |> put_status(200)
            |> render("milestone.json", %{milestone: milestone})

          {:error, _} ->
            conn
            |> put_status(500)
            |> json("not inserted")
        end
    end
  end

  def update(conn, %{"id" => id, "milestone" => milestone_params}) do
    milestone = MilestoneModel.get_milestone!(id)

    case MilestoneModel.update_milestone(milestone, milestone_params) do
      {:ok, %Milestone{} = milestone} ->
        conn
        |> put_status(200)
        |> render("milestone.json", %{milestone: milestone})

      {:error, milestone} ->
        conn
        |> put_status(422)
        |> json("not updated")
    end
  end

  def delete(conn, %{"id" => id}) do
    milestone = MilestoneModel.get_milestone!(id)

    with {:ok, _} <- MilestoneModel.delete_milestone(milestone) do
      send_resp(conn, 200, "milestone deleted successfully")
    end
  end
end
