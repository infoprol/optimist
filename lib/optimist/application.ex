defmodule Optimist.Application do
  @moduledoc "scratch server to play with optimistic http locking (RFC 7232)"

  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Optimist.Endpoint,
        options: [port: 1337]
      ),
      {FakeDb.Things, []}
    ]

    opts = [strategy: :one_for_one, name: Optimist.Supervisor]
    ans = Supervisor.start_link(children, opts)

    IO.puts("now serving on port 1337...")
    ans
  end
end
