defmodule Dailyploy.Model.ReportConfiguration do
  # import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.ReportConfiguration
  # alias Dailyploy.Schema.Project
  # alias Dailyploy.Schema.User

  def create(params) do
    changeset = ReportConfiguration.changeset(%ReportConfiguration{}, params)
    Repo.insert(changeset)
  end

  def delete(report_configuration) do
    Repo.delete(report_configuration)
  end

  def update(%ReportConfiguration{} = report_configuration, params) do
    changeset = ReportConfiguration.changeset(report_configuration, params)
    Repo.update(changeset)
  end

  def get(id), do: Repo.get(ReportConfiguration, id)

  # def get_all(project) do
  #   query =
  #     from contact in Contact,
  #       where: contact.project_id == ^project.id,
  #       select: contact

  #   Repo.all(query) |> Repo.preload(:project)
  # end

  # def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
  #   paginated_recurring_data =
  #    ReportConfiguration |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  #   recurring_data_with_preloads = paginated_recurring_data.entries |> Repo.preload(preloads)
  #   paginated_response(recurring_data_with_preloads, paginated_recurring_data)
  # end
end
