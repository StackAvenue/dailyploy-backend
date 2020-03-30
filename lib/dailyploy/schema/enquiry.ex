defmodule Dailyploy.Schema.Enquiry do
  use Ecto.Schema
  import Ecto.Changeset

  schema("enquires") do
    field :phone_number, :string, size: 10
    field :email, :string
    field :name, :string
    field :comment, :string
    field :company_name, :string
    timestamps()
  end

  @optional_required_params ~w(name company_name email phone_number)a

  def changeset(enquiry, attrs) do
    enquiry
    |> cast(attrs, [:phone_number, :email, :name, :comment, :company_name])
    |> validate_required(@optional_required_params)
    |> validate_length(:phone_number, is: 10)
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
