defmodule MemoryWeb.Router do
  use MemoryWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:put_user_token)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :auth do
    plug(:has_current_user)
  end

  scope "/", MemoryWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    post("/join", PageController, :join)

    pipe_through(:auth)
    get("/game/:game", PageController, :game)
  end

  # Other scopes may use custom stacks.
  # scope "/api", MemoryWeb do
  #   pipe_through :api
  # end

  defp put_user_token(conn, _) do
    if current_user = get_session(conn, :current_user) do
      token = Phoenix.Token.sign(conn, "user socket", current_user)
      assign(conn, :user_token, token)
    else
      conn
    end
  end

  defp has_current_user(conn, _) do
    case get_session(conn, :current_user) do
      nil ->
        conn
        |> put_flash(:error, "Please join game with username")
        |> redirect(to: "/")
        |> halt()

      _ ->
        conn
    end
  end
end
