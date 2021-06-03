defmodule Todo.Cache do
  def start_link() do
    IO.puts("Starting to-do cache.")

    DynamicSupervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def server_process(name) do
    existing_process(name) || new_process(name)
  end

  defp existing_process(name) do
    Todo.Server.whereis(name)
  end

  defp new_process(name) do
    case DynamicSupervisor.start_child(__MODULE__, {Todo.Server, name}) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end
