defmodule AerpplaneWeb.PageController do
  use AerpplaneWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
