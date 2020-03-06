defmodule Dailyploy.Model.User do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Role
  alias Dailyploy.Schema.UserWorkspace
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.UserProject
  alias Dailyploy.Schema.UserWorkspaceSetting
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Model.UserWorkspaceSetting, as: UWSModel
  alias Auth.Guardian
  import Ecto.Query
  import Comeonin.Bcrypt

  @spec list_users :: any
  def list_users() do
    Repo.all(User)
  end

  def list_users(workspace_id) do
    query =
      from(user_workspace in UserWorkspace,
        join: user in User,
        on: user_workspace.user_id == user.id,
        join: role in Role,
        on: user_workspace.role_id == role.id,
        where: user_workspace.workspace_id == ^workspace_id,
        select: %{user | role: role.name}
      )

    Repo.all(query)
  end

  def generate_query(params) do
    query =
      from(project in Project,
        where: project.workspace_id == ^params.workspace_id
      )
  end

  def filter_users(params) do
    query =
      from(user in User,
        join: user_workspace in UserWorkspace,
        on:
          user_workspace.user_id == user.id and
            user_workspace.workspace_id == ^params.workspace_id,
        left_join: user_project in UserProject,
        on: user_project.user_id == user.id,
        join: role in Role,
        on: role.id == user_workspace.role_id,
        where: ^filter_where(params),
        distinct: true,
        select: %{user | role: role.name}
      )

    Repo.all(query)
  end

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:workspace_id, workspace_id}, dynamic_query ->
        dynamic(
          [user, user_workspace, user_project, role],
          ^dynamic_query and user_workspace.workspace_id == ^workspace_id
        )

      {:user_ids, user_ids}, dynamic_query ->
        user_ids = Enum.map(String.split(user_ids, ","), fn x -> String.to_integer(x) end)

        dynamic(
          [user, user_workspace, user_project, role],
          (^dynamic_query and user.id in ^user_ids) or user_project.user_id in ^user_ids
        )

      {:project_ids, project_ids}, dynamic_query ->
        project_ids = Enum.map(String.split(project_ids, ","), fn x -> String.to_integer(x) end)

        dynamic(
          [user, user_workspace, user_project, role],
          ^dynamic_query and user_project.project_id in ^project_ids
        )

      {_, _}, dynamic_query ->
        dynamic_query
    end)
  end

  def list_users(workspace_id, user_ids) do
    query =
      from(user_workspace in UserWorkspace,
        join: user in User,
        on: user_workspace.user_id == user.id,
        join: role in Role,
        on: user_workspace.role_id == role.id,
        where: user_workspace.workspace_id == ^workspace_id and user.id in ^user_ids,
        select: %{user | role: role.name}
      )

    Repo.all(query)
  end

  def list_user_workspace_setting(user_id, workspace_id) do
    from(user_workspace_setting in UserWorkspaceSetting,
      where:
        user_workspace_setting.user_id == ^user_id and
          user_workspace_setting.workspace_id == ^workspace_id
    )
    |> Repo.all()
    |> List.first()
  end

  def task_summary_report_data(params) do
    task_ids = TaskModel.task_ids_for_criteria(params)
    # total_estimated_time = TaskModel.total_estimated_time(task_ids, params)
    total_capacity_time = UWSModel.capacity(params)
    total_tracked_time = TaskModel.user_summary_report_data(task_ids, params)
    %{total_estimated_time: total_capacity_time, total_tracked_time: total_tracked_time}
  end

  def get(id) when is_integer(id) do
    case Repo.get(User, id) do
      nil ->
        {:error, "not found"}

      task ->
        {:ok, task}
    end
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id), do: Repo.get(User, id)

  def get_user!(id, preloads), do: Repo.get!(User, id) |> Repo.preload(preloads)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def create_google_user(attrs \\ %{}) do
    %User{}
    |> User.changeset_google_auth(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def google_sign_in(email, provider_id) do
    with {:ok, user} <- get_by_email(email) do
      case verify_token(user, email, provider_id) do
        {:ok, user} ->
          Guardian.encode_and_sign(user)

        _ ->
          {:error, :unauthorized}
      end
    else
      {:error, _message} -> {:error, "Email Doesn't Exist"}
    end
  end

  def token_sign_in(email, password) do
    case email_password_auth(email, password) do
      {:ok, user} ->
        Guardian.encode_and_sign(user)

      _ ->
        {:error, :unauthorized}
    end
  end

  def token_sign_in_check(email, password) do
    case email_password_auth(email, password) do
      {:ok, user} ->
        Guardian.encode_and_sign(user)

      _ ->
        {:error, 403}
    end
  end

  defp email_password_auth(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, user} <- get_by_email(email),
         do: verify_password(password, user)
  end

  def get_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        Bcrypt.no_user_verify()
        {:error, "Email does not match"}

      user ->
        {:ok, user}
    end
  end

  defp verify_token(user, email, provider_id) do
    if user.provider_id == provider_id and user.email == email do
      {:ok, user}
    else
      {:error, :invalid_token}
    end
  end

  defp verify_password(password, %User{} = user) when is_binary(password) do
    if Bcrypt.verify_pass(password, user.password_hash) do
      {:ok, user}
    else
      {:error, :invalid_password}
    end
  end

  def get_current_workspace(user) do
    query =
      from user_workspace in UserWorkspace,
        join: workspace in Workspace,
        on: user_workspace.workspace_id == workspace.id,
        where: user_workspace.user_id == ^user.id and workspace.type == "individual"

    user_workspaces = Repo.all(query) |> Repo.preload(:workspace)
    user_workspace = List.first(user_workspaces)

    case user_workspace do
      nil -> nil
      _ -> user_workspace.workspace
    end
  end

  def get_admin_user_query do
    admin_role = Repo.get_by(Role, name: "admin")

    from user in User,
      join: userWorkspace in UserWorkspace,
      where: userWorkspace.role_id == ^admin_role.id
  end
end
