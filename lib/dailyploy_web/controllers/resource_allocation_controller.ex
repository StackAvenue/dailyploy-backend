defmodule DailyployWeb.ResourceAllocationController do
  use DailyployWeb, :controller
  import Plug.Conn

  alias Dailyploy.Model.ResourceAllocation
  alias Dailyploy.Model.UserProject, as: UserProjectModel
  alias Dailyploy.Schema.UserProject

  def index(conn, %{"workspace_id" => workspace_id}) do
    project_members = ResourceAllocation.fetch_project_members(workspace_id)

    render(conn, "show.json", project_members: project_members)
  end

  def create(conn, %{"member_id" => user_id, "project_id" => project_id}) do
    case UserProjectModel.create_user_project(%{
      user_id: user_id,
      project_id: project_id
    }) do
      {:ok, %UserProject{} = userproject} ->
        conn
        |> put_status(200)
        |> json(%{"message" => "User added to project"})

      {:error, _} ->
        conn
        |> put_status(500)
        |> json(%{"error" => "User already present"})
    end
  end

  def delete(conn, %{"id" => user_id, "project_id" => project_id}) do
     case ResourceAllocation.delete_user_project(user_id, project_id) do
      {:ok, %UserProject{} = userproject} ->
        conn
        |> put_status(200)
        |> json(%{"message" => "Deleted"})
      nil ->
        conn
        |> put_status(404)
        |> json("error")
     end
  end
end
