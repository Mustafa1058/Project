defmodule Solutions do
    import Ecto.Query

    alias Project.Repo
    
    def replace_string({string, list} = input) do
        Enum.with_index(list|> Enum.reverse)
        |> Enum.reduce(string, fn (i, acc) -> 
            {value, index} = i
            
            acc = String.replace(acc, ["\n"], "")
            
            (if (length(list) > index), do: String.replace(acc, "$#{length(list) - index}", "#{value}"), else: acc)
        end)|> IO.gets
    end

    def string_uppercase(list), do: Enum.map(list, & String.upcase(&1)) 

    def flatten(list), do: List.flatten(list)

    def get_users() do
       users = Repo.all from u in User

       users |> Enum.map(fn user -> 
        %{
            name: user.name,
            age: user.age,
            salary: user.salary,
            phone: user.phone
        }
       end)
    end
end