# Script for populating the database. You can run it as:
#
#     mix run priv/repo/status_sequence.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Dailyploy.Repo.insert!(%Dailyploy.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Dailyploy.Helper.Seed.Status

Status.seed_sequence()
