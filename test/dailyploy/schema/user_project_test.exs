defmodule Dailyploy.Schema.UserProjectTest do
  use Dailyploy.ModelCase
  alias Dailyploy.Schema.UserProject

  @valid_attrs %{
   user_id: "1",
   project_id: "2"
  }

  @invalid_attrs %{user_id: nil, task_status_id: nil}

  test "changeset with valid data" do
    changeset = UserProject.changeset(%UserProject{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid data" do
    changeset = UserProject.changeset(%UserProject{}, @invalid_attrs)
    refute changeset.valid?
  end
end
