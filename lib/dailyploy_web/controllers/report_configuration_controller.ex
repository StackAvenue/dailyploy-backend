defmodule DailyployWeb.ReportConfigurationController do
  use DailyployWeb, :controller
  alias Dailyploy.Helper.ReportConfiguration
  import DailyployWeb.Helpers
  import DailyployWeb.Validators.ReportConfiguration
  alias Dailyploy.Model.UserWorkspace, as: UWModel
  alias Dailyploy.Model.ReportConfiguration, as: RCModel
  # alias Dailyploy.Model.User, as: UserModel

  plug :check_adminship when action in [:create]
  plug :load_report_config when action in [:update, :delete, :show]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_report_configuration(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, report_configuration}} <-
               {:create, ReportConfiguration.create_report_configuration(data)} do
          conn
          |> put_status(200)
          |> render("show.json", %{report_configuration: report_configuration})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Either user is not admin or resource not found")
    end
  end

  @spec delete(Plug.Conn.t(), any) :: Plug.Conn.t()
  def delete(conn, _params) do
    case conn.status do
      nil ->
        case RCModel.delete(conn.assigns.report_configuration) do
          {:ok, report_configuration} ->
            conn
            |> put_status(200)
            |> render("show.json", %{report_configuration: report_configuration})

          {:error, report_configuration} ->
            error = extract_changeset_error(report_configuration)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{report_configuration: report_configuration}} = conn

        case RCModel.update(report_configuration, params) do
          {:ok, report_configuration} ->
            conn
            |> put_status(200)
            |> render("show.json", %{report_configuration: report_configuration})

          {:error, report_configuration} ->
            error = extract_changeset_error(report_configuration)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def show(conn, _params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("show.json", %{report_configuration: conn.assigns.report_configuration})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp check_adminship(
         %{params: %{"admin_id" => admin_id, "workspace_id" => workspace_id}} = conn,
         _params
       ) do
    case UWModel.check_adminship(admin_id, workspace_id) do
      {:ok, role} ->
        assign(conn, :role, role)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp load_report_config(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case RCModel.get(id) do
      nil ->
        conn
        |> put_status(404)

      report_configuration ->
        assign(conn, :report_configuration, report_configuration)
    end
  end
end
