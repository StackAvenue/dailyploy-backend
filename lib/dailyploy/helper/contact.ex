defmodule Dailyploy.Helper.Contact do
  alias Dailyploy.Repo
  alias Dailyploy.Model.Contact, as: ContactModel
  import DailyployWeb.Helpers

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
end
