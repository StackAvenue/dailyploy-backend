defmodule Dailyploy.Schema.ContactTest do
  use Dailyploy.ModelCase
  alias Dailyploy.Schema.Contact

  @valid_attrs %{
    phone_number: "123456789",
    email: "user12@gmail.com",
    project_id: "1"
  }

  @invalid_attrs %{phone_number: 12, email: 12}

  test "changeset with valid data" do
    changeset = Contact.changeset(%Contact{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid data" do
    changeset = Contact.changeset(%Contact{}, @invalid_attrs)
    refute changeset.valid?
  end
end
