defmodule DailyployWeb.Plug.TaskLists do
  import Plug.Conn
  alias Dailyploy.Model.TaskLists, as: TSModel

  def init(default), do: default

  def call(
        %{params: %{"task_lists_id" => id}} = conn,
        _params
      ) do
    load_task_list(conn, id)
  end

  def call(
        %{params: %{"user_stories_id" => id}} = conn,
        _params
      ) do
    load_user_stories(conn, id)
  end

  defp load_user_stories(conn, id) do
    {id, _} = Integer.parse(id)

    case USModel.get(id) do
      {:ok, user_stories} ->
        assign(conn, :user_stories, user_stories)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp load_task_list(conn, id) do
    {id, _} = Integer.parse(id)

    case TSModel.get(id) do
      {:ok, task_list} ->
        assign(conn, :task_list, task_list)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
