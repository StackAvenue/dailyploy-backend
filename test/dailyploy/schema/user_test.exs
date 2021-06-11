defmodule Dailyploy.Schema.UserTest do
  use Dailyploy.ModelCase
  alias Dailyploy.Schema.User

  @valid_attrs %{
    name: "User",
    email: "user@mail.com",
    password: "123456789",
    password_confirmation: "123456789"
  }

  @invalid_attrs %{name: 12, email: 12}


  test "changeset with valid data" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid data" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset does not accept invalid email address" do
    attrs = Map.put(@valid_attrs, :email, "wrongemail#mail.com")
    changeset = User.changeset(%User{}, attrs)
    assert "has invalid format" in errors_on(changeset, :email)
  end

  test "changeset does not accept names with special characters" do
    attrs = Map.put(@valid_attrs, :name, "wrong/name?!")
    changeset = User.changeset(%User{}, attrs)
    assert "has invalid format" in errors_on(changeset, :name)
  end

  test "changeset does not accept taken email address" do
    attrs = Map.put(@valid_attrs, :email, "user@gmail.com")

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()

    changeset_2 = User.changeset(%User{}, attrs)

    {:error, changeset} = Repo.insert(changeset_2)
    refute changeset.valid?
  end
end
