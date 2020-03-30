defmodule Dailyploy.Model.Enquiry do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Enquiry
  import DailyployWeb.Helpers

  def create_enquiry(params) do
    changeset = Enquiry.changeset(%Enquiry{}, params)
    Repo.insert(changeset)
  end

  def create_enquiries(params) do
    %{
      name: name,
      email: email,
      phone_number: phone_number,
      company_name: company_name,
      comment: comment
    } = params

    verify_enquiry(
      create_enquiry(%{
        name: name,
        email: email,
        phone_number: phone_number,
        company_name: company_name,
        comment: comment
      })
    )
  end

  defp verify_enquiry({:ok, enquiry}) do
    {:ok, enquiry}
  end

  defp verify_enquiry({:error, enquiry}) do
    {:error, extract_changeset_error(enquiry)}
  end
end
