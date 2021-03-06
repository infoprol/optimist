defmodule Optimist.Endpoint do
  @moduledoc """
  ripped off of https://dev.to/jonlunsford/elixir-building-a-small-json-endpoint-with-plug-cowboy-and-poison-1826
  to get base plug pipeline
  """

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)  # match the routed path
  #plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)  # return conn from plug pipeline

  get "/ping" do
    IO.inspect(%{"conn" => conn})
    send_resp(conn, 200, "pong!")
  end


  #alias FakeDb.{Things}


  get "/things/:thing_id" do
    #things_pid()
    #|> looksee("pid_get_got")
    thing_id
    |> looksee("thing_id in endpoint.get")
    |> FakeDb.Things.fetch()
    |> looksee("result of fetch returned to endpoint.get")
    |> Poison.encode!()
    |> looksee("endpoint encoded by Poison")
    |> (fn x -> send_resp(conn, 200, x) end).()
  end

  put "/things/:thing_id" do
    {:ok, body, conn}= Plug.Conn.read_body(conn)
    body |> looksee("body")
    looksee(conn, "conn")
    thing_id
    |> looksee("thing_id in endpoint.put")
    |> FakeDb.Things.put(
        body |> Poison.decode!()
        #conn.body_params |> Poison.decode!()
      )

      send_resp(conn, 200, "awesome put, great job!")
  end




  match _ do
    send_resp(conn, 404, "oh no, not again...")
  end


  defp things_pid() do
    Supervisor.which_children(Optimist.Supervisor)
    |> looksee("children")
    |> Enum.map(
      fn x ->
        case x do
          {FakeDb.Things, pid, _, _} -> pid
          _ -> false
        end
      end
    )
    |> looksee()
    |> Enum.filter(fn x ->
      case x do
        false -> false
        _ -> true
      end
    end)
    |> looksee("pid")
  end


  defp looksee(x, label \\ "unlabeled") do
    IO.inspect(%{ label => x})
    x
  end



end
