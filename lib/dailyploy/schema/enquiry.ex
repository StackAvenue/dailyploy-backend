defmodule Dailyploy.Schema.Enquiry do
  use Ecto.Schema
  import Ecto.Changeset

  schema("enquires") do
    field :phone_number, :string
    field :email, :string
    field :name, :string
    field :comment, :string
    field :company_name, :string
    timestamps()
  end

  @required_params ~w(name email phone_number)a
  @optional_params ~w(company_name)a

  @permitted @required_params ++ @optional_params

  def changeset(enquiry, attrs) do
    enquiry
    |> cast(attrs, @permitted)
    |> validate_required(@required_params)
  end

  # need to be done for phonenumbers
  # defp validate_inclusion(changeset, fields) do
  #   present = Enum.count(fields, fn field -> present?(get_field(changeset, field)) end)

  #   case present do
  #     0 ->
  #       add_error(
  #         changeset,
  #         :missing_error,
  #         "Either phone-number or email is required, both can't be empty"
  #       )

  #     _ ->
  #       changeset
  #   end
  # end

  # defp present?(nil), do: false
  # defp present?(""), do: false
  # defp present?(_), do: true
end
