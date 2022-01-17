defmodule Holidays.Repo.Migrations.CreateDays do
  use Ecto.Migration

  def change do
    create table(:days) do
      add :name, :string
      add :h_date, :date
    end
  end
end
