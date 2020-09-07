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
