defmodule Dailyploy.Schema.TaskTest do
  use Dailyploy.ModelCase
  alias Dailyploy.Schema.Task

  @valid_attrs %{
    name: "dailyploy",
    start_datetime: ~U[2021-06-10 00:00:00Z],
    end_datetime: ~U[2021-06-10 00:00:00Z],
    project_id: "1",
    owner_id: "2",
    task_status_id: "3",
    is_complete: true
  }

  @invalid_attrs %{name: 1
  }

  test "changeset with valid data" do
    changeset = Task.changeset(%Task{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid data" do
    changeset = Task.changeset(%Task{}, @invalid_attrs)
    refute changeset.valid?
  end
end
