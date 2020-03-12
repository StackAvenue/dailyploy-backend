defmodule DailyployWeb.ContactController do
  use DailyployWeb, :controller
  alias Dailyploy.Repo
  alias Dailyploy.Helper.Contact
  alias Dailyploy.Model.Contact, as: ContactModel
  alias Dailyploy.Model.Project, as: ProjectModel
  import DailyployWeb.Validators.Contact
  import DailyployWeb.Helpers

  plug :load_project when action in [:create, :index]
  plug :load_contact when action in [:update, :delete, :show]

  def index(conn, params) do
    case conn.status do
      nil ->
        contacts = ContactModel.get_all(conn.assigns.project)

        conn
        |> put_status(200)
        |> render("index.json", %{contacts: contacts})

      404 ->
        conn
        |> send_error(404, "Data is not sufficient.")
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_contact(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, contact}} <- {:create, Contact.create_contact(data)} do
          conn
          |> put_status(200)
          |> render("show.json", %{contact: contact})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Data is not sufficient.")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{contact: contact}} = conn

        case ContactModel.update_contact(contact, params) do
          {:ok, contact} ->
            conn
            |> put_status(200)
            |> render("show.json", %{contact: contact})

          {:error, contact} ->
            error = extract_changeset_error(contact)

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
        |> render("show.json", %{contact: conn.assigns.contact})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, params) do
    case conn.status do
      nil ->
        case ContactModel.delete_contact(conn.assigns.contact) do
          {:ok, contact} ->
            conn
            |> put_status(200)
            |> render("show.json", %{contact: contact})

          {:error, contact} ->
            error = extract_changeset_error(contact)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_project(
         %{params: %{"project_id" => project_id}} = conn,
         _params
       ) do
    {project_id, _} = Integer.parse(project_id)

    case ProjectModel.get(project_id) do
      {:ok, project} ->
        assign(conn, :project, project)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp load_contact(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)
    # asd = ContactModel.get(id)
    case ContactModel.get(id) do
      nil ->
        conn
        |> put_status(404)

      contact ->
        assign(conn, :contact, contact)
    end
  end
end
