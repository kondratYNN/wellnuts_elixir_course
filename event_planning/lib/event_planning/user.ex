defmodule EventPlanning.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :role, :string
    has_many :event, EventPlanning.Event

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :role])
    |> validate_required([:email, :role])
    |> validate_inclusion(:role, ["admin", "user"])
  end
end
