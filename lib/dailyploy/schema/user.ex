defmodule DailyPloy.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias DailyPloy.Model.User


  schema "users" do
    field :name, :string
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :password_confirmation])
  end
end
