defmodule AeroplaneWeb.GamesChannel do
    use AeroplaneWeb, :channel
    alias Aeroplane.Game
    # alias Aeroplane.BackupAgent
  
    def join("games:" <> name, payload, socket) do
      if authorized?(payload) do
        # game = BackupAgent.get(name) || Game.new()
        # BackupAgent.put(name, game)
        game = Game.new()
        socket = socket
        |> assign(:game, game)
        |> assign(:name, name)
        {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
      else
        {:error, %{reason: "unauthorized"}}
      end
    end

    def handle_in("on_click_piece", %{"index" => ii}, socket) do
        name = socket.assigns[:name]
        # replace Game.move with actual function name
        game = Game.clickPiece(socket.assigns[:game], ii)
        socket = assign(socket, :game, game)
        # BackupAgent.put(name, game)
        {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
    end

    def handle_in("on_click_die", %{}, socket) do
      name = socket.assigns[:name]
      # replace Game.move with actual function name
      game = Game.clickDie(socket.assigns[:game])
      socket = assign(socket, :game, game)
      # BackupAgent.put(name, game)
      {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end
  
    # Add authorization logic here as required.
    defp authorized?(_payload) do
      true
    end
  end