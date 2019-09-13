# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Dailyploy.Repo.insert!(%Dailyploy.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Dailyploy.Schema.Role
alias Dailyploy.Repo

Repo.insert!(Role.changeset(%Role{}, %{name: "owner"}))
Repo.insert!(Role.changeset(%Role{}, %{name: "admin"}))
Repo.insert!(Role.changeset(%Role{}, %{name: "member"}))
