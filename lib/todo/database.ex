defmodule Todo.Database do
  @pool_size 3
  @db_folder "./persist"

  def start_link do
    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end

  defp worker_spec(worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end
end

# Worker

defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link({folder, worker_id}) do
    IO.puts("Starting to-do database worker #{worker_id}.")
    GenServer.start_link(__MODULE__, folder, name: via_tuple(worker_id))
  end

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  @impl true
  def init(folder) do
    File.mkdir_p!(folder)
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

  defp via_tuple(worker_id) do
    Todo.Registry.via_tuple({__MODULE__, worker_id})
  end
end
