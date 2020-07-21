defmodule DailyployWeb.EnquiryController do
  use DailyployWeb, :controller
  alias Dailyploy.Helper.Enquiry, as: EnquiryHelper
  alias Dailyploy.Model.Enquiry, as: EModel
  import DailyployWeb.Helpers
  import DailyployWeb.Validators.Enquiry

  def create(conn, params) do
    changeset = verify_enquiry(params)

    with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
         {:create, {:ok, enquiry}} <- {:create, EModel.create_enquiries(data)} do
      EnquiryHelper.build_email(conn, enquiry)

      conn
      |> put_status(200)
      |> json(%{"Message" => "Thanks for your interest, we will contact you soon"})
    else
      {:extract, {:error, error}} ->
        send_error(conn, 400, error)

      {:create, {:error, message}} ->
        send_error(conn, 400, message)
    end
  end
end
