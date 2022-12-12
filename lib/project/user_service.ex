defmodule UserService do
    import Ecto.Query
    alias Project.Cache

    @cache_table :project_users
    @all_key :all

    def get_data() do
        fetch_chached_data(@cache_table, @all_key, fn () -> Project.Repo.all from u in User end)
    end
    
    def create(params) do
        insert_data(@cache_table, params)
    end

    def update(name, params) do
        with \
            user  <- (Project.Repo.one from u in User, where: u.name == ^name),
            {:ok, user} <- update_data(@cache_table, user, params)
        do
            {:ok, user}
        end
    end

    def delete(name) do
        with \
            user  <- (Project.Repo.one from u in User, where: u.name == ^name),
            _   <- delete_user(@cache_table, user)
        do
            :ok
        end
    end

    defp fetch_chached_data(cache_table, key, func) do
        case Cache.get(cache_table, key) do
            status when status == :not_found ->
                set_cached_data(cache_table, key, func)
            data when is_list(data) -> get_chached_data_in_list(data)
            {:ok, value} -> {:ok, value}
        end
    end

    defp get_chached_data_in_list(data) do
        result = 
        data |> Enum.map(fn {key, value, expiry} ->
            case check_expired(value, expiry) do
                {:ok, value} -> value
                :expired -> nil
            end
        end)|> Enum.uniq|> Enum.filter(& &1)
        if result == [], do: [], else: result
    end

    defp check_expired(value, expiry) do
        cond do
          expiry > :os.system_time(:seconds) -> {:ok, value}
          true -> :expired
        end
    end

    defp set_cached_data(cache_table, key, func) do
        case func.() do
            data when is_list(data) -> 
                Enum.map(data, fn user -> 
                   Cache.set(cache_table, user.name|> String.to_atom, user)
                end)
                data
            _ -> {:error, :not_found}
        end
    end

    defp insert_data(cache_table, params) do
        {:ok, data} =
            %User{}
            |> User.changeset(params)
            |> Project.Repo.insert()

        if data do
            Cache.set(cache_table, data.name|> String.to_atom, data)
        else
            {:ok, []}
        end 
    end

    defp delete_user(cache_table, user) do
        Project.Repo.delete(user)
        Cache.delete(cache_table, user.name|> String.to_atom())
    end

    defp update_data(cache_table, user, params) do
        {:ok, user} =
            user
            |> User.changeset(params)
            |> Project.Repo.update()
            
        if user do
            Cache.update(cache_table, user.name|> String.to_atom, user)
        else
            {:ok, []}
        end 
    end
end