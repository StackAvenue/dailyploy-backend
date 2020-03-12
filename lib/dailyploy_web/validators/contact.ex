defmodule DailyployWeb.Validators.Contact do
  use Params

  defparams(
    verify_contact(%{
      project_id!: :integer,
      name: :string,
      email: :string,
      phone_number: :string
    })
  )
end
