defmodule Dailyploy.Schema.WorkspaceTest do
  use Dailyploy.ModelCase
  alias Dailyploy.Schema.Workspace

  @valid_attrs %{
    name: "Project",
    type: "individual"
  }

  @invalid_attrs %{name: 12, type: 12}

  test "changeset with valid data" do
    changeset = Workspace.changeset(%Workspace{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid data" do
    changeset = Workspace.changeset(%Workspace{}, @invalid_attrs)
    refute changeset.valid?
  end
end
