defmodule AeroplaneWeb.PageController do
  use AeroplaneWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
