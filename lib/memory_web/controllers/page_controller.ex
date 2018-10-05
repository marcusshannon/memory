defmodule MemoryWeb.PageController do
  use MemoryWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def game(conn, %{"game" => id}) do
    conn
    |> redirect(to: "/game/#{id}")
  end

  def room(conn, %{"id" => id}) do
    render(conn, "game.html", id: id)
  end
end
