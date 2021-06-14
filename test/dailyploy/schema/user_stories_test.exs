defmodule Dailyploy.Schema.UserStoriesTest do
  use Dailyploy.ModelCase
  alias Dailyploy.Schema.UserStories

  @valid_attrs %{
    name: "dailyploy",
    description: "project",
    is_completed: true,
    priority: "high",
    due_date: nil,
    task_status_id: "1",
    owner_id: "2",
    task_lists_id: "1"
  }

  @invalid_attrs %{user_id: nil, task_status_id: nil}

  test "changeset with valid data" do
    changeset = UserStories.changeset(%UserStories{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid data" do
    changeset = UserStories.changeset(%UserStories{}, @invalid_attrs)
    refute changeset.valid?
  end
end
