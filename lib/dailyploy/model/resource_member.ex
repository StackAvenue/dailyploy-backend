defmodule Dailyploy.Model.ResourceMember do
  alias Dailyploy.Repo

  alias Dailyploy.Schema.UserWorkspace
  alias Dailyploy.Schema.User

  import Ecto.Query

  def get_all(params) do
    %{
      "page_size" => page_size,
      "page_number" => page_number,
      "workspace_id" => workspace_id
    } = params

    query =
      from(user in User,
        join: user_workspace in UserWorkspace,
        on:
          user_workspace.user_id == user.id and
            user_workspace.workspace_id == ^workspace_id,
        distinct: true,
        order_by: user.name
      )

    paginated_project_data = Repo.paginate(query, page: page_number, page_size: page_size)
    paginated_response(paginated_project_data)
  end

  defp paginated_response(pagination_data) do
    %{
      entries: pagination_data.entries,
      page_number: pagination_data.page_number,
      page_size: pagination_data.page_size,
      total_entries: pagination_data.total_entries,
      total_pages: pagination_data.total_pages
    }
  end
end
