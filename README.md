# TodoCache

ToDo lists management application in Elixir.

### Process Registration

These are the different types of process registration in Elixir/Erlang:

1. The basic registration facility is a local registration that allows you to use a simple atom as an alias to the single process on a node.
2. `Registry` extends this by letting you use rich aliases - any term can be used as an alias.
3. `:global` allows you to register a cluster-wide alias.
4. `:pg` is useful for registering multiple processes behind a cluster-wide alias (process group), which is usually suitable for distributed pub-sub scenarios.

### :rpc module

Allows you to issue a function call on all nodes in the cluster, this module could be use to replicate data in the entire cluster.

### How to fetch all dependencies

`mix deps.get`