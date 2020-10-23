defmodule Dailyploy.Helper.UserStories do
  alias Dailyploy.Model.UserStories
  import DailyployWeb.Helpers

  defdelegate update(user_story, params), to: UserStories
  defdelegate create_attachment(changeset), to: UserStories
  defdelegate delete_attachments(ids, user_stories), to: UserStories

  def create(params) do
    params = params_extraction(params)
    verify_user_stories(UserStories.create(params))
  end

  def verify_user_stories({:ok, user_stories}) do
    {:ok, user_stories}
  end

  def verify_user_stories({:error, message}) do
    {:error, %{error: extract_changeset_error(message)}}
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end
end
