defmodule Todo.Application do
  use Application

  @impl true
  def start(_type, _args) do
    Todo.System.start_link()
  end
end
