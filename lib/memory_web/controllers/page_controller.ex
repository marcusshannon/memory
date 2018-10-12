defmodule MemoryWeb.PageController do
  use MemoryWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def join(conn, %{"user" => user, "game" => game}) do
    conn
    |> put_session(:current_user, user)
    |> redirect(to: "/game/#{game}")
  end

  def game(conn, %{"game" => game}) do
    render(conn, "game.html", game: game)
  end
end
