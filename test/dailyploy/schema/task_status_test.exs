defmodule Dailyploy.Schema.TaskStatusTest do
  use Dailyploy.ModelCase
  alias Dailyploy.Schema.TaskStatus

  @valid_attrs %{
    name: "user",
    sequence_no: 123456,
    is_default: true,
    workspace_id: 1,
    project_id: 2
  }

  @invalid_attrs %{workspace_id: nil, project_id: nil}

  test "changeset with valid data" do
    changeset = TaskStatus.changeset(%TaskStatus{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid data" do
    changeset = TaskStatus.changeset(%TaskStatus{}, @invalid_attrs)
    refute changeset.valid?
  end
end
