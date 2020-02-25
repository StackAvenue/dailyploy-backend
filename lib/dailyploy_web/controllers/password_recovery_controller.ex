defmodule DailyployWeb.PasswordRecoveryController do
  use DailyployWeb, :controller
  alias Dailyploy.Helper.ForgotPassword, as: FPModel

  def generate_email(conn, %{"email" => email}) do
    case FPModel.fetch_credentials(email) do
      :ok ->
        conn
        |> put_status(200)
        |> json(%{"mail_sent" => true})

      message ->
        conn
        |> put_status(401)
        |> json(%{"message" => message})
    end
  end
end
