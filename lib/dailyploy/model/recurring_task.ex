defmodule Dailyploy.Model.RecurringTask do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.RecurringTask
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.UserProject
  alias Dailyploy.Model.Project, as: ProjectModel
  alias Dailyploy.Model.User, as: UserModel

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

  # def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
  #   paginated_recurring_data =
  #    RecurringTask |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  #   recurring_data_with_preloads = paginated_recurring_data.entries |> Repo.preload(preloads)
  #   paginated_response(recurring_data_with_preloads, paginated_recurring_data)
  # end

  def get_all(preloads) do
    query = from recurring_task in RecurringTask, distinct: true

    Repo.all(query)
  end

  def attach_project(params) do
    project_ids = Map.keys(params)
    ProjectModel.extract_project(project_ids)
  end

  def attach_member(params) do
    member_ids =
      Enum.reduce(params, [], fn {key, value}, acc ->
        acc = acc ++ value
      end)

    UserModel.extract_user(member_ids)
  end

  # defp paginated_response(data, pagination_data) do
  #   %{
  #     entries: data,
  #     page_number: pagination_data.page_number,
  #     page_size: pagination_data.page_size,
  #     total_entries: pagination_data.total_entries,
  #     total_pages: pagination_data.total_pages
  #   }
  # end
end
