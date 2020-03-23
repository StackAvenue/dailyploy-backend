defmodule DailyployWeb.RecurringTaskController do
  use DailyployWeb, :controller
  alias Dailyploy.Repo
  import DailyployWeb.Helpers
  alias Dailyploy.Helper.RecurringTask
  import DailyployWeb.Validators.RecurringTask
  alias Dailyploy.Model.RecurringTask, as: RTModel
  alias Dailyploy.Model.Project, as: ProjectModel
  alias Dailyploy.Model.User, as: UserModel

  plug :load_recurring_task when action in [:update, :show, :delete]
  plug :check_project_member_inclusion when action in [:create]

  def create(conn, %{"task" => task_params, "workspace_id" => workspace_id} = params) do
    task_params =
      task_params
      |> Map.put_new("workspace_id", workspace_id)
      |> Map.put_new("project_members_combination", conn.assigns.hash_list)
      |> Map.replace!("project_ids", map_to_list(task_params["project_ids"]))
      |> Map.replace!("member_ids", map_to_list(task_params["member_ids"]))

    task_params =
      case Map.has_key?(task_params, "month_numbers") do
        false ->
          Map.put_new(task_params, "month_numbers", nil)

        true ->
          Map.replace!(task_params, "month_numbers", map_to_list(task_params["month_numbers"]))
      end

    task_params =
      case Map.has_key?(task_params, "number") do
        false -> Map.put_new(task_params, "number", nil)
        true -> Map.replace!(task_params, "number", String.to_integer(task_params["number"]))
      end

    task_params =
      case Map.has_key?(task_params, "week_numbers") do
        false ->
          Map.put_new(task_params, "week_numbers", nil)

        true ->
          Map.replace!(task_params, "week_numbers", map_to_list(task_params["week_numbers"]))
      end

    changeset = verify_recurring_task(task_params)

    with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
         {:create, {:ok, recurring_task}} <- {:create, RecurringTask.create_recurring_task(data)} do
      conn
      |> put_status(200)
      |> render("show.json", %{recurring_task: recurring_task})
    else
      {:extract, {:error, error}} ->
        send_error(conn, 400, error)

      {:create, {:error, message}} ->
        send_error(conn, 400, message)
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{recurring_task: recurring_task}} = conn

        params = change_to_list(params, recurring_task)

        case RTModel.update(recurring_task, params) do
          {:ok, recurring_task} ->
            conn
            |> put_status(200)
            |> render("show.json", %{recurring_task: recurring_task})

          {:error, recurring_task} ->
            error = extract_changeset_error(recurring_task)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def show(conn, params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("show.json", %{recurring_task: conn.assigns.recurring_task})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, params) do
    case conn.status do
      nil ->
        case RTModel.delete(conn.assigns.recurring_task) do
          {:ok, recurring_task} ->
            conn
            |> put_status(200)
            |> render("show.json", %{recurring_task: recurring_task})

          {:error, recurring_task} ->
            error = extract_changeset_error(recurring_task)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_recurring_task(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case RTModel.get(id) do
      nil ->
        conn
        |> put_status(404)

      recurring_task ->
        assign(conn, :recurring_task, recurring_task)
    end
  end

  defp check_project_member_inclusion(
         %{
           params: %{
             "task" => %{"project_ids" => project_ids, "member_ids" => member_ids},
             "workspace_id" => workspace_id
           }
         } = conn,
         _params
       ) do
    project_ids = map_to_list(project_ids) |> check_project(workspace_id)
    member_ids = map_to_list(member_ids) |> check_members(workspace_id)
    project_member_ids = ProjectModel.extract_members(project_ids)
    project_members_combination = extract_member_ids(project_member_ids, member_ids)
    assign(conn, :hash_list, project_members_combination)
  end

  defp check_project(project_ids, workspace_id) do
    ProjectModel.extract_valid_project_ids(project_ids, workspace_id)
  end

  def extract_member_ids(hash_list, member_ids) do
    Enum.reduce(hash_list, %{}, fn {k, v}, acc ->
      acc =
        case Map.has_key?(acc, k) do
          true ->
            acc

          false ->
            v = Enum.filter(v, fn el -> Enum.member?(member_ids, el) end)
            Map.put_new(acc, k, v)
        end
    end)
  end

  defp check_members(member_ids, workspace_id) do
    UserModel.extract_valid_user_ids(member_ids, workspace_id)
  end

  defp map_to_list(user_ids) do
    user_ids
    |> String.split(",")
    |> Enum.map(fn x -> String.to_integer(String.trim(x, " ")) end)
  end

  defp change_to_list(params, recurring_task) do
    params =
      case Map.has_key?(params, "month_numbers") do
        false ->
          params

        true ->
          Map.replace!(params, "month_numbers", map_to_list(params["month_numbers"]))
      end

    params =
      case Map.has_key?(params, "number") do
        false -> params
        true -> Map.replace!(params, "number", String.to_integer(params["number"]))
      end

    params =
      case Map.has_key?(params, "week_numbers") do
        false ->
          params

        true ->
          Map.replace!(params, "week_numbers", map_to_list(params["week_numbers"]))
      end

    params =
      case Map.has_key?(params, "member_ids") do
        false ->
          case Map.has_key?(params, "project_ids") do
            false ->
              params

            true ->
              project_members_combination =
                fix_combination(
                  map_to_list(params["project_ids"]),
                  recurring_task.member_ids,
                  recurring_task.workspace_id
                )

              project_ids =
                map_to_list(params["project_ids"]) |> check_project(recurring_task.workspace_id)

              Map.replace!(params, "project_ids", project_ids)
              |> Map.put_new("project_members_combination", project_members_combination)
          end

        true ->
          case Map.has_key?(params, "project_ids") do
            false ->
              project_members_combination =
                fix_combination(
                  recurring_task.project_ids,
                  map_to_list(params["member_ids"]),
                  recurring_task.workspace_id
                )

              member_ids =
                map_to_list(params["member_ids"]) |> check_members(recurring_task.workspace_id)

              Map.replace!(params, "member_ids", member_ids)
              |> Map.put_new("project_members_combination", project_members_combination)

            true ->
              project_members_combination =
                fix_combination(
                  map_to_list(params["project_ids"]),
                  map_to_list(params["member_ids"]),
                  recurring_task.workspace_id
                )

              project_ids =
                map_to_list(params["project_ids"]) |> check_project(recurring_task.workspace_id)

              member_ids =
                map_to_list(params["member_ids"]) |> check_members(recurring_task.workspace_id)

              Map.replace!(params, "project_ids", project_ids)
              |> Map.put_new("project_members_combination", project_members_combination)
              |> Map.replace!("member_ids", member_ids)
          end
      end
  end

  defp fix_combination(project_ids, member_ids, workspace_id) do
    project_ids = project_ids |> check_project(workspace_id)
    member_ids = member_ids |> check_members(workspace_id)
    project_member_ids = ProjectModel.extract_members(project_ids)
    project_members_combination = extract_member_ids(project_member_ids, member_ids)
  end
end
