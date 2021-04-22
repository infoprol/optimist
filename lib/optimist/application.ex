defmodule Optimist.Application do
  @moduledoc "scratch server to play with optimistic http locking (RFC 7232)"

  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Optimist.Endpoint,
        options: [port: 1337])]

    opts = [strategy: :one_for_one, name: Optimist.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
