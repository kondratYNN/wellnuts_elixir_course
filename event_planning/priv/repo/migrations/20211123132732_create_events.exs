defmodule EventPlanning.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :date, :utc_datetime
      add :repetition, :string

      timestamps()
    end
  end
end
