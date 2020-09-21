defmodule DailyployWeb.Plug.UserStories do
  import Plug.Conn
  alias Dailyploy.Model.UserStories, as: USModel

  def init(default), do: default

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
end
