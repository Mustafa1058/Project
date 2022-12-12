defmodule User do
    use Ecto.Schema
    import Ecto.Changeset
    
    schema "users" do
        field :name, :string
        field :age, :integer
        field :salary, :integer
        field :phone, :string

        timestamps()
    end

    def changeset(struct, params) do
        struct
        |> cast(params, [:name, :age, :salary, :phone])
    end
end