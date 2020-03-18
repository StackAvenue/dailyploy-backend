defmodule DailyployWeb.EnquiryController do
  use DailyployWeb, :controller
  alias Dailyploy.Repo
  alias Dailyploy.Model.Enquiry, as: EModel
  import DailyployWeb.Helpers

  def create(conn, params) do
    with {:ok, enquiry} <- EModel.create_enquiry(params) do
      conn
      |> put_status(200)
      |> json(%{"Message" => "Thanks for your interest, we will contact you soon"})
    else
      {:error, error} ->
        conn
        |> put_status(404)
        |> json(%{"Message" => "Please fill correct data"})
    end
  end
end
