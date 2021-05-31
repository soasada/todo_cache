defmodule Todo.List do
  defstruct id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %Todo.List{},
      fn %{date: date, title: title}, todo_list_acc ->
        add_entry(todo_list_acc, date, title)
      end
    )
  end

  def add_entry(%Todo.List{id: id, entries: entries}, date, title) do
    entry = %{id: id, date: date, title: title}
    new_entries = Map.put(entries, id, entry)
    %Todo.List{id: id + 1, entries: new_entries}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(todo_list, id, updater) do
    case Map.fetch(todo_list.entries, id) do
      :error -> todo_list
      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater.(old_entry) # 1. We are matching that updater lambda returns a map %{}
                                                               # 2. ^var means that you are matching on the value of the variable
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, id) do
    %Todo.List{todo_list | entries: Map.delete(todo_list.entries, id)}
  end
end
