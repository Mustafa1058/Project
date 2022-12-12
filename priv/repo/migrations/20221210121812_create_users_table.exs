defmodule Project.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
   create table(:users) do
     add :name, :string
     add :age, :integer
     add :salary, :bigint

     timestamps()
   end
  end
end
