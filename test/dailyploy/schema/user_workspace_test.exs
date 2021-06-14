defmodule Dailyploy.Schema.UserWorkspaceTest do
  use Dailyploy.ModelCase
  alias Dailyploy.Schema.UserWorkspace

  @valid_attrs %{
    workspace_id: 1,
    user_id: 2,
    role_id: 3
  }

  @invalid_attrs %{workspace_id: nil, user_id: nil}

  test "changeset with valid data" do
    changeset = UserWorkspace.changeset(%UserWorkspace{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid data" do
    changeset = UserWorkspace.changeset(%UserWorkspace{}, @invalid_attrs)
    refute changeset.valid?
  end
end
