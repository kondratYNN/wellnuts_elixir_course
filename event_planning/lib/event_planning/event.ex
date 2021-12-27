defmodule EventPlanning.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :date, :utc_datetime
    field :repetition, :string

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:date, :repetition])
    |> validate_required([:date, :repetition])
    |> validate_inclusion(:repetition, [
      "day",
      "week",
      "month",
      "year",
      "none"
    ])
  end
end
