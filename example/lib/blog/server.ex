if Mix.env() != :prod do
  defmodule Moonshine.Server do
    @moduledoc """
    Server _site for development purposes
    """

    use Plug.Router

    plug(:match)
    plug(:dispatch)

    get "/" do
      send_file(conn, "index.html")
    end

    get "/:slug" do
      cond do
        File.exists?("_site/#{slug}") -> send_file(conn, slug)
        File.exists?("_site/#{slug}.html") -> send_file(conn, "#{slug}.html")
        true -> send_resp(conn, 404, "not_found")
      end
    end

    match _ do
      send_resp(conn, 404, "not found")
    end

    defp send_file(conn, file) do
      send_file(conn, 200, "_site/#{file}")
    end
  end
end
