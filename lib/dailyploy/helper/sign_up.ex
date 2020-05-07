defmodule Dailyploy.Helper.SignUp do
  alias SendGrid.{Mail, Email}

  def build_email(conn, enquiry) do
    user_email(conn, enquiry)
    # personal_email(enquiry)
  end

  defp user_email(conn, enquiry) do
    personalization_1 =
      Email.build()
      |> Email.add_to(enquiry.email)
      |> Email.put_subject("Thanks For Enquiring")
      |> Email.to_personalization()

    personalization_2 =
      Email.build()
      |> Email.add_to("enquiries@dailyploy.com")
      |> Email.put_subject("New inquiry received for a demo")
      |> Email.to_personalization()

    Email.build()
    |> Email.put_from("contact@stack-avenue.com")
    |> Email.put_subject("Thanks for Enquiring !")
    |> Email.put_phoenix_view(DailyployWeb.EmailView)
    |> Email.put_phoenix_template("sign_up_email.html", user: enquiry)
    |> Email.add_personalization(personalization_1)
    # |> Email.add_personalization(personalization_2)
    |> Mail.send()

    Email.build()
    |> Email.put_from("contact@stack-avenue.com")
    |> Email.put_subject("New inquiry received for a demo")
    |> Email.put_phoenix_view(DailyployWeb.EmailView)
    |> Email.put_phoenix_template("sign_up_self_enquiry.html", user: enquiry)
    # |> Email.add_personalization(personalization_1)
    |> Email.add_personalization(personalization_2)
    |> Mail.send()
  end
end
