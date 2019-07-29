defmodule DailyployWeb.TagController do
  use DailyployWeb, :controller
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Model.Tag, as: TagModel
  alias Dailyploy.Schema.Tag


  plug :load_workspace_by_id
  plug :load_tag_by_id_in_workspace when action in [:update, :delete, :show]

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"tag" => tag_params}) do
    tag_params = Map.put(tag_params, "workspace", conn.assigns.workspace)
    case TagModel.create_tag(tag_params) do
      {:ok, %Tag{} = tag} ->
        render(conn, "show.json", tag: tag)
      {:error, tag} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: tag.errors})
    end
  end

  @spec update(Plug.Conn.t(), map) :: Plug.Conn.t()
  def update(conn, %{"tag" => tag_params}) do
    tag = conn.assigns.tag
    tag_params = Map.put(tag_params, "workspace", conn.assigns.workspace)
    case TagModel.update_tag(tag, tag_params) do
      {:ok, %Tag{} = tag} ->
        render(conn, "show.json", tag: tag)
      {:error, tag} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: tag.errors})
    end
  end

  @spec delete(Plug.Conn.t(), any) :: Plug.Conn.t()
  def delete(conn, _) do
    tag = conn.assigns.tag
    case TagModel.delete_tag(tag) do
      {:ok, _tag} ->
        send_resp(conn, 202, "Tag Deleted successfully")
      _ ->
        conn
        |> put_status(422)
        render("error_in_deletion.json", %{})
    end
  end

  def index(conn, _) do
    tags = TagModel.list_tags_in_workspace(%{workspace_id: conn.assigns.workspace.id})
    render(conn, "index.json", tags: tags)
  end

  def show(conn, _) do
    tag = TagModel.get_tag_in_workspace!(%{workspace_id: conn.assigns.workspace.id, tag_id: conn.assigns.tag.id})
    render(conn, "show.json", %{tag: tag})
  end

  defp load_workspace_by_id(%{params: %{"workspace_id" => id}} = conn, _) do
    # WorkspaceModel.get_workspace_by_user(%{user_id: Guardian.plug.current_resource, workspace_id: id})
    case WorkspaceModel.get_workspace!(id) do
      %Workspace{} = workspace ->
        assign(conn, :workspace, workspace)
      _ -> send_resp(conn, 404, "Resource Not Found")
    end
  end

  defp load_tag_by_id_in_workspace(%{params: %{"workspace_id" => workspace_id, "id" => tag_id}} = conn, _) do
    case TagModel.get_tag_in_workspace!(%{workspace_id: workspace_id, tag_id: tag_id}, [:workspace]) do
      %Tag{} = tag ->
        assign(conn, :tag, tag)
      _ -> send_resp(conn, 404, "Resource Not Found")
    end
  end
end
