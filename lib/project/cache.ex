defmodule Project.Cache do
    use GenServer
  
    # Start the server
    def start_link() do
      GenServer.start_link(__MODULE__, %{}, name: ProjectCache)
    end
  
    def init(state) do
      {:ok, state}
    end
  
    def set(table, key, value) do
      GenServer.cast(ProjectCache, {:set, table, key, value})
    end

    def update(table, key, value) do
      GenServer.cast(ProjectCache, {:put, table, key, value})
    end
  
    def delete(table) do
      GenServer.cast(ProjectCache, {:delete, table})
    end
    def delete(table, key) do
      GenServer.cast(ProjectCache, {:delete, table, key})
    end
  
    def clear(table) do
      GenServer.cast(ProjectCache, {:clear, table})
    end
  
    def get(table, key) do
      GenServer.call(ProjectCache, {:get, table, key})
    end
  
    # handle calls
    def handle_cast({:set, table, key, value}, state) do
      try_create_table(table) 
      time_to_keep = 20 
      expiration = :os.system_time(:seconds) + time_to_keep
      :ets.insert(table, {key, value, expiration})
      {:noreply, state}
    end
    def handle_cast({:put, table, key, value}, state) do
      :ets.update_element(table, key, value)
      {:noreply, state}
    end
    def handle_cast({:delete, table}, state) do
      case :ets.info(table) do
        :undefined -> :not_found
        _ -> :ets.delete(table)
      end
      {:noreply, state}
    end
    def handle_cast({:delete, table, key}, state) do
      case :ets.info(table) do
        :undefined -> :not_found
        _ -> :ets.delete(table, key)
      end
      {:noreply, state}
    end
    def handle_cast({:clear, table}, state) do
      case :ets.info(table) do
        :undefined -> :not_found
        _ -> :ets.delete_all_objects(table)
      end
      {:noreply, state}
    end
  
    def handle_call({:get, table, key}, _from, state) do
      try_create_table(table)
      # retrieve saved data
      result = case :ets.tab2list(table) do
        [] -> :not_found
        data -> data
      end
      {:reply, result, state}
    end
  
    defp try_create_table(table) do
      # create table if it does not exist
      case :ets.info(table) do
        :undefined -> :ets.new(table, [:set, :public, :named_table])
        _ -> :ok
      end
    end
  end