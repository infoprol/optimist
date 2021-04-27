defmodule FakeDb.Things do
  use Agent

  def start_link(arg) do
    IO.puts("FakeDb.Things.start_link started!")
    IO.inspect(%{ "start_link_args" => arg })

    {:ok, pid} = Agent.start_link(fn -> %{} end, name: __MODULE__)
    #IO.puts("pid of fakeness => #{(pid)}")
    IO.inspect(%{"fdb.pid" => pid})
    {:ok, pid}
  end

  def fetch(pid, key) do
    IO.inspect(%{"things.get.args" => [pid, key]})
    Agent.get(__MODULE__, &Map.get(&1, key))
    |> (fn x ->
        IO.inspect(x)
        x end).()
  end

  def put(pid, key, val) do
    Agent.update(__MODULE__, &Map.put(&1, key, val))
  end











  def loop(acc \\ 0) do
    IO.inspect(%{"acc" => acc})
    case acc do
      0 -> send(self(), "wrong week to quit sniffing glue!")
      _ -> IO.inspect(%{"you send it!" => self()})
    end

    receive do
      {:message_type, value} ->
        IO.inspect([value, "got message_type"])
        loop(acc)
      :stop -> IO.puts("byeeee")
      _ -> loop(acc + 1)
    end

  end


#  def child_spec(opts) do
#    %{
#      id: __MODULE__,
#      start: {__MODULE__, :start_link, [opts]},
#      type: :worker,
#      restart: :permanent,
#      shutdown: 666
#    }
# end
end
