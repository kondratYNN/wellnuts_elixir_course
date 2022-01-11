defmodule EventPlanning.Event do
  use Ecto.Schema
  import Ecto.Changeset
  @name_length 6

  schema "events" do
    field :name, :string
    field :date, :utc_datetime
    field :repetition, :string

    timestamps()
  end

  def has_name(event) do
    case get_field(event, :name) do
      nil -> put_change(event, :name, random_string(@name_length))
      _else -> event
    end
  end

  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :date, :repetition])
    |> validate_required([:name, :date, :repetition])
    |> has_name()
    |> validate_inclusion(:repetition, [
      "day",
      "week",
      "month",
      "year",
      "none"
    ])
  end
end
