defmodule Dailyploy.Schema.CompanyTest do
  use Dailyploy.ModelCase
  alias Dailyploy.Schema.Company

  @valid_attrs %{
    name: "User",
    email: "user12@gmail.com",
    workspace: %{
      name: "Project",
      type: "individual"
    }
  }

  @invalid_attrs %{name: 12, email: 12}

  test "changeset with valid data" do
    changeset = Company.changeset(%Company{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid data" do
    changeset = Company.changeset(%Company{}, @invalid_attrs)
    refute changeset.valid?
  end
end
