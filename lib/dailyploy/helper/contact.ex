defmodule Dailyploy.Helper.Contact do
  alias Dailyploy.Model.Contact, as: ContactModel
  import DailyployWeb.Helpers
  alias SendGrid.{Mail, Email}

  def create_contact(params) do
    %{
      project_id: project_id,
      name: name,
      email: email,
      phone_number: phone_number
    } = params

    verify_create(
      ContactModel.create_contact(%{
        project_id: project_id,
        name: name,
        email: email,
        phone_number: phone_number
      })
    )
  end

  defp verify_create({:ok, contact}) do
    contact = contact |> Dailyploy.Repo.preload([:project])

    {:ok,
     %{
       id: contact.id,
       project_id: contact.project_id,
       name: contact.name,
       email: contact.email,
       phone_number: contact.phone_number,
       project: contact.project
     }}
  end

  defp verify_create({:error, contact}) do
    {:error, extract_changeset_error(contact)}
  end

  def send_email(task, contact) do
    user_email(task, contact)
  end

  defp user_email(task, contact) do
    Email.build()
    |> Email.add_to(contact.email)
    |> Email.put_from("Dailyploy@stack-avenue.com")
    |> Email.put_subject("Task Completed")
    |> Email.put_phoenix_view(DailyployWeb.EmailView)
    |> Email.put_phoenix_template("contact.html", task: task)
    |> Mail.send()
  end
end
