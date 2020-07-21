defmodule DailyployWeb.Validators.Enquiry do
  use Params

  defparams(
    verify_enquiry(%{
      name!: :string,
      company_name: :string,
      email!: :string,
      phone_number!: :string,
      comment: :string
    })
  )
end
