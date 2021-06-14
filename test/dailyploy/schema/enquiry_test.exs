defmodule Dailyploy.Schema.EnquiryTest do
  use Dailyploy.ModelCase
  alias Dailyploy.Schema.Enquiry

  @valid_attrs %{
    name: "User",
    email: "user12@gmail.com",
    phone_number: "123456789"
  }

  @invalid_attrs %{name: 12, email: 12}

  test "changeset with valid data" do
    changeset = Enquiry.changeset(%Enquiry{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid data" do
    changeset = Enquiry.changeset(%Enquiry{}, @invalid_attrs)
    refute changeset.valid?
  end
end
