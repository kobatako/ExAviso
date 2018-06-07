defmodule ExAviso.DataStorage do
  alias :ets, as: Ets

  @tags :tags

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    Ets.new(@tags, [:set, :named_table, :private])
    {:ok, %{@tags => 1}}
  end

  def handle_cast({}, t) do
    {:noreply, t}
  end

  def handle_call({:fetch, table, id}, _from, t) do
    res = Ets.lookup(table, id)
    {:reply, res, t}
  end

  def handle_call({:first, table}, _from, t) do
    id = Ets.first(table)
    res = Ets.lookup(table, id)
    {:reply, res, t}
  end

  def handle_call({:next, table, id}, _from, t) do
    res_id = Ets.next(table, id)
    res = Ets.lookup(table, res_id)
    {:reply, res, t}
  end

  def handle_call({:all, table}, _from, t) do
    res =
      case Ets.first(table) do
        :"$end_of_table" ->
          []

        item_id ->
          all_list(table, item_id, Ets.lookup(table, item_id))
      end

    {:reply, res, t}
  end

  defp all_list(table, id, lists) do
    case Ets.next(table, id) do
      :"$end_of_table" ->
        lists

      item_id ->
        all_list(table, item_id, lists ++ Ets.lookup(table, item_id))
    end
  end

  def handle_call({:insert, table, obj}, _from, t) do
    id = t[@tags]
    res_id = Ets.insert(table, Tuple.insert_at(obj, 0, id))
    res = Ets.lookup(table, res_id)
    {:reply, res, Map.replace!(t, @tags, id + 1)}
  end

  def get!(table, id) do
    GenServer.call(__MODULE__, {:fetch, table, id})
  end

  def first(table) do
    GenServer.call(__MODULE__, {:fetch, table, 1})
  end

  def next(table, id) do
    GenServer.call(__MODULE__, {:next, table, id})
  end

  def all(table) do
    GenServer.call(__MODULE__, {:all, table})
  end

  def insert!(table, obj) when is_tuple(obj) do
    GenServer.call(__MODULE__, {:insert, table, obj})
  end
end
