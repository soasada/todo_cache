defmodule TodoCacheTest do
  use ExUnit.Case

  test "server_process should return to-do server pid" do
    # {:ok, cache} = Todo.Cache.start() ----- not needed because we have converted the system into an OTP Application
    bob_pid = Todo.Cache.server_process("bob")

    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")
  end

  test "to-do operations" do
    # {:ok, cache} = Todo.Cache.start()
    alice_pid = Todo.Cache.server_process("alice")
    Todo.Server.add(alice_pid, ~D[2018-12-19], "Dentist")
    entries = Todo.Server.entries(alice_pid, ~D[2018-12-19])

    assert [%{date: ~D[2018-12-19], title: "Dentist"}] = entries
  end
end
