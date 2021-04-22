defmodule Optimist.Endpoint do
  @moduledoc """
  ripped off of https://dev.to/jonlunsford/elixir-building-a-small-json-endpoint-with-plug-cowboy-and-poison-1826
  to get base plug pipeline
  """

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)  # match the routed path
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)  # return conn from plug pipeline

  get "/ping" do
    send_resp(conn, 200, "pong!")
  end

  match _ do
    send_resp(conn, 404, "oh no, not again...")
  end






end