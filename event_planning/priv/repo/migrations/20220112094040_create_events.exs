defmodule EventPlanning.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :date, :utc_datetime
      add :repetition, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create(index(:events, [:user_id]))
  end
end
