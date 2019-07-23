defmodule Dailyploy.Schema.Company do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Workspace

  schema "companies" do
    field :name, :string
    field :email, :string
    has_one :workspaces, Workspace
    timestamps()
  end

  def changeset(company, attrs) do
    company
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> unique_constraint(:email)
  end
end
