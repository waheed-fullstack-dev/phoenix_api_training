defmodule PhoenixApi.Repo.Migrations.AlterUsersAddPasswordField do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password, :string
      add :is_active, :boolean
      add :address, :string
      add :city, :string
      add :state, :string
      add :postal_code, :integer
    end
  end
end
