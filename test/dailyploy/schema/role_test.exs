defmodule Dailyploy.Schema.RoleTest do
  use Dailyploy.ModelCase
  alias Dailyploy.Schema.Role

  @valid_attrs %{
    name: "User"
  }

  @invalid_attrs %{name: 1}

  test "changeset with valid data" do
    changeset = Role.changeset(%Role{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid data" do
    changeset = Role.changeset(%Role{}, @invalid_attrs)
    refute changeset.valid?
  end
end
