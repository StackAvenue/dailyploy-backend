defmodule Dailyploy.Model.Contact do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Contact

  def create_contact(params) do
    changeset = Contact.changeset(%Contact{}, params)
    Repo.insert(changeset)
  end

  def delete_contact(contact) do
    Repo.delete(contact)
  end

  def update_contact(%Contact{} = contact, params) do
    changeset = Contact.update_changeset(contact, params)
    Repo.update(changeset)
  end

  def get(id), do: Repo.get(Contact, id) |> Repo.preload([:project])

  def get_all(project) do
    query =
      from contact in Contact,
        where: contact.project_id == ^project.id,
        select: contact

    Repo.all(query) |> Repo.preload(:project)
  end
end
