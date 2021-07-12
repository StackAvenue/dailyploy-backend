defmodule Dailyploy.Factory do
  @moduledoc """
  Factory for creating test data.
  """
  use ExMachina.Ecto, repo: Dailyploy.Repo

  alias Dailyploy.Schema.{
    User,
    Workspace,
    Company,
    Project
  }

  def user_factory do
    %User{
      name: "User",
      email: sequence(:email, &"dailyployuser-#{&1}@email.com"),
      password: "password",
      password_confirmation: "password"
    }
  end

  def workspace_factory do
    %Workspace{
      name: "Dailyploy",
      type: Enum.random(["individual", "company"]),
      currency: Enum.random(["INR", "USD"]),
      timetrack_enabled: True
    }
  end

  def company_factory do
    %Company{
      name: "Dailyploy",
      email: sequence(:email, &"dailyployuser-#{&1}@email.com")
    }
  end

  def project_factory do
    %Project{
      name: "Dailyploy",
      start_date: Timex.now()
    }
  end
end
