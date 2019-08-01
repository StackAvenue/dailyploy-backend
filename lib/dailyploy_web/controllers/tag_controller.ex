defmodule DailyployWeb.TagController do
  use DailyployWeb, :controller
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Model.Tag, as: TagModel
  alias Dailyploy.Schema.Tag

  plug Auth.Pipeline
  plug :load_workspace_by_user
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

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _) do
    tags = TagModel.list_tags_in_workspace(%{workspace_id: conn.assigns.workspace.id})
    render(conn, "index.json", tags: tags)
  end

  @spec show(Plug.Conn.t(), any) :: Plug.Conn.t()
  def show(conn, _) do
    tag = TagModel.get_tag_in_workspace!(%{workspace_id: conn.assigns.workspace.id, tag_id: conn.assigns.tag.id})
    render(conn, "show.json", %{tag: tag})
  end

  defp load_workspace_by_user(%{params: %{"workspace_id" => id}} = conn, _) do
    case WorkspaceModel.get_workspace_by_user(%{user_id: Guardian.Plug.current_resource(conn).id, workspace_id: id}) do
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
