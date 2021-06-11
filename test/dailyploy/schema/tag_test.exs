defmodule Dailyploy.Schema.TagTest do
  use Dailyploy.ModelCase
  alias Dailyploy.Schema.Tag

  @valid_attrs %{
    name: "User",
    color: "red",
    workspace_id: "1"
  }

  @invalid_attrs %{name: 12, color: 12}

  test "changeset with valid data" do
    changeset = Tag.changeset(%Tag{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid data" do
    changeset = Tag.changeset(%Tag{}, @invalid_attrs)
    refute changeset.valid?
  end
end
