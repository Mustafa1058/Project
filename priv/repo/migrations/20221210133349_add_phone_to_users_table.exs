defmodule Project.Repo.Migrations.AddPhoneToUsersTable do
  use Ecto.Migration

  def change do
    alter table :users do
      add :phone, :string
    end
  end
end
