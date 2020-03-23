defmodule Dailyploy.Model.RecurringTask do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.RecurringTask

  def create(params) do
    changeset = RecurringTask.changeset(%RecurringTask{}, params)
    Repo.insert(changeset)
  end

  def delete(recurring_task) do
    Repo.delete(recurring_task)
  end

  def update(%RecurringTask{} = recurring_task, params) do
    changeset = RecurringTask.update_changeset(recurring_task, params)
    Repo.update(changeset)
  end

  def get(id), do: Repo.get(RecurringTask, id) |> Repo.preload([:category, :workspace])

  # def get_all(project) do
  #   query =
  #     from contact in Contact,
  #       where: contact.project_id == ^project.id,
  #       select: contact

  #   Repo.all(query) |> Repo.preload(:project)
  # end
end
