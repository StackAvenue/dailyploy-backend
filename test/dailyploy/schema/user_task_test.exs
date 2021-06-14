defmodule Dailyploy.Schema.UserTaskTest do
  use Dailyploy.ModelCase
  alias Dailyploy.Schema.UserTask

  @valid_attrs %{
    user_id: "1",
    task_id: "2"
  }

  @invalid_attrs %{user_id: nil, task_id: nil}

  test "changeset with valid data" do
    changeset = UserTask.changeset(%UserTask{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid data" do
    changeset = UserTask.changeset(%UserTask{}, @invalid_attrs)
    refute changeset.valid?
  end
end
