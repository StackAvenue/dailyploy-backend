defmodule Dailyploy.Model.Enquiry do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Enquiry

  def create_enquiry(params) do
    changeset = Enquiry.changeset(%Enquiry{}, params)
    Repo.insert(changeset)
  end
end
