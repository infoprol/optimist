defmodule FakeDb.Things do
  def start_link(arg) do
    IO.puts("FakeDb.Things.start_link started!")
    IO.inspect(%{ "start_link_args" => arg })

    {:ok, pid} = Process.spawn(__MODULE__.loop, [])
    IO.puts("pid of fakeness => " <> to_string(pid))
    IO.inspect(%{"fdb.pid" => pid})
    {:ok, pid}
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



  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 666
    }
  end
end
