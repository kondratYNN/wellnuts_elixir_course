defmodule Holidays.Day do
  use Ecto.Schema
  import Ecto.Changeset

  schema "days" do
    field :name, :string
    field :h_date, :date
  end

  def changeset(day, params \\ %{}) do
    day
    |> cast(params, [:name, :h_date])
    |> validate_required([:name, :h_date])
  end
end
