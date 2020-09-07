defmodule Dailyploy.Helper.RoadmapChecklist do
  alias Dailyploy.Model.RoadmapChecklist, as: RCModel
  import DailyployWeb.Helpers

  defdelegate get_all(data, preloads, task_lists_id), to: RCModel
  defdelegate update(checklist, params), to: RCModel
  defdelegate delete(checklist), to: RCModel

  def create(params) do
    %{
      name: name,
      task_lists_id: task_lists_id,
      is_completed: is_completed
    } = params

    verify_create(
      RCModel.create(%{
        name: name,
        task_lists_id: task_lists_id,
        is_completed: is_completed
      })
    )
  end

  defp verify_create({:ok, checklist}) do
    {:ok,
     %{
       id: checklist.id,
       name: checklist.name,
       is_completed: checklist.is_completed
     }}
  end

  defp verify_create({:error, checklist}) do
    {:error, extract_changeset_error(checklist)}
  end
end
