defmodule Dailyploy.Helper.ForgotPassword do
  alias SendGrid.{Mail, Email}
  alias Dailyploy.Model.User, as: UserModel
  import Comeonin.Bcrypt

  def fetch_credentials(email) do
    case UserModel.get_by_email(email) do
      {:error, message} -> message
      {:ok, user} -> generate_newpassword(user)
    end
  end

  defp generate_newpassword(user) do
    password = :crypto.strong_rand_bytes(8) |> Base.url_encode64() |> binary_part(0, 8)
    attrs = %{}

    attrs =
      attrs
      |> Map.put_new(:password, password)
      |> Map.put_new(:password_confirmation, password)
      |> Map.put_new(:email, user.email)
      |> Map.put_new(:name, user.name)

    # attrs = Map.replace!(user, :password_hash, password_hash.password_hash)
    {:ok, user_update} = UserModel.update_user(user, attrs)
    send_email(user_update)
  end

  defp send_email(user_update) do
    user_update
    |> build_email
  end

  defp build_email(user_update) do
    Email.build()
    |> Email.add_to(user_update.email)
    |> Email.put_from("contact@stack-avenue.com")
    |> Email.put_subject("Password Reset")
    |> Email.put_phoenix_view(DailyployWeb.EmailView)
    |> Email.put_phoenix_template("password_reset.html",
      user: user_update
    )
    |> Mail.send()
  end
end
