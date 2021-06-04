defmodule Todo.Database do
  @db_folder "./persist"

  def store_local(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.store(worker_pid, key, data)
      end
    )
  end

  def store(key, data) do
    {_results, bad_nodes} = :rpc.multicall(
      __MODULE__,
      :store_local,
      [key, data],
      :timer.seconds(5) # very important, without this timeout the store operation would be blocked forever
    )

    Enum.each(bad_nodes, &IO.puts("Store failer on node #{&1}"))
    :ok
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.get(worker_pid, key)
      end
    )
  end

  def child_spec(_) do
    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: 3
      ],
      [@db_folder]
    )
  end
end

# Worker

defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link(folder) do
    IO.puts("Starting to-do database worker.")
    GenServer.start_link(__MODULE__, folder)
  end

  def store(worker_id, key, data) do
    GenServer.call(worker_id, {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(worker_id, {:get, key})
  end

  @impl true
  def init(folder) do
    File.mkdir_p!(folder <> "/" <> to_string(node()))
    {:ok, folder}
  end

  @impl true
  def handle_cast({:store, key, data}, folder) do
    folder
    |> file_name(key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, folder}
  end

  @impl true
  def handle_call({:get, key}, _, folder) do
    data = case File.read(file_name(folder, key)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      {:error, :enoent} -> nil
    end

    {:reply, data, folder}
  end

  defp file_name(folder, key) do
    Path.join(folder, to_string(key))
  end
end
