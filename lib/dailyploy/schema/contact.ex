defmodule Dailyploy.Schema.Contact do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Project

  schema("contacts") do
    belongs_to :project, Project
    field :phone_number, :string, size: 10
    field :email, :string
    field :name, :string

    timestamps()
  end

  @required_params ~w(project_id)a
  @optional_required_params ~w(email phone_number)a
  @optional_params ~w(phone_number email name)a

  @params @required_params ++ @optional_params

  def changeset(contact, attrs) do
    contact
    |> cast(attrs, @params)
    |> validate_required(@required_params)
    |> common_changeset
    |> validate_inclusion(@optional_required_params)
  end

  def update_changeset(contact, attrs) do
    contact
    |> cast(attrs, @params)
    |> common_changeset
  end

  defp common_changeset(changeset) do
    changeset
    |> validate_format(:email, ~r/^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,})$/)
    |> validate_length(:phone_number, size: 10)
    |> validate_format(:phone_number, ~r/^[0-9]*$/)
    |> unique_constraint(:email,
      name: :unique_contact_index
    )
  end

  defp validate_inclusion(changeset, fields) do
    present = Enum.count(fields, fn field -> present?(get_field(changeset, field)) end)

    case present do
      0 ->
        add_error(
          changeset,
          :missing_error,
          "Either phone-number or email is required, both can't be empty"
        )

      _ ->
        changeset
    end
  end

  defp present?(nil), do: false
  defp present?(""), do: false
  defp present?(_), do: true
end
