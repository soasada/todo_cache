defmodule Todo.Server do
  use GenServer, restart: :temporary

  @expiry_idle_timeout :timer.seconds(10)

  def start_link(name) do
    IO.puts("Starting to-do server for #{name}.")
    GenServer.start_link(__MODULE__, name, name: global_name(name))
  end

  def whereis(name) do
    case :global.whereis_name({__MODULE__, name}) do
      :undefined -> nil
      pid -> pid
    end
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def add(pid, date, title) do
    GenServer.call(pid, {:add, date, title})
  end

  @impl true
  def init(name) do
    send(self(), {:real_init, name})
    {:ok, nil, @expiry_idle_timeout}
  end

  @impl true
  def handle_call({:add, date, title}, _, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, date, title)
    Todo.Database.store(name, new_list)
    {:reply, :ok, {name, new_list}, @expiry_idle_timeout}
  end

  @impl true
  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}, @expiry_idle_timeout}
  end

  @impl true
  def handle_info({:real_init, name}, _) do
    IO.puts("Real init of #{name}")
    {:noreply, {name, Todo.Database.get(name) || Todo.List.new()}, @expiry_idle_timeout}
  end

  @impl true
  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping to-do server for #{name}")
    {:stop, :normal, {name, todo_list}}
  end

  defp global_name(name) do
    {:global, {__MODULE__, name}}
  end
end
