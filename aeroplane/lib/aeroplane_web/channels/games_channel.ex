defmodule AeroplaneWeb.GamesChannel do
    use AeroplaneWeb, :channel
    alias Aeroplane.Game
    alias Aeroplane.BackupAgent
    alias Aeroplane.GameServer

    def join("games:" <> name, payload, socket) do
      if authorized?(payload) do
        GameServer.start(name)
        game = GameServer.peek(name)
        BackupAgent.put(name, game)
        socket = socket
        |> assign(:name, name)
        {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
      else
        {:error, %{reason: "unauthorized"}}
      end
    end

    def handle_in("on_click_piece", %{"index" => ii}, socket) do
        name = socket.assigns[:name]
        case GameServer.on_click_piece(name, ii) do
          [st1, st2, st3] ->
            broadcast!(socket, "update", %{ "game" => Game.client_view(st1) })
            Process.send_after(self(), {:timeoutUpdate, st2}, 300)
            Process.send_after(self(), {:timeoutUpdate, st3}, 600)
            {:reply, {:ok, %{ "game" => Game.client_view(st1)}}, socket}
          [st1, st2] ->
            broadcast!(socket, "update", %{ "game" => Game.client_view(st1) })
            Process.send_after(self(), {:timeoutUpdate, st2}, 300)
            {:reply, {:ok, %{ "game" => Game.client_view(st1)}}, socket}
          st1 ->
            broadcast!(socket, "update", %{ "game" => Game.client_view(st1) })
            {:reply, {:ok, %{ "game" => Game.client_view(st1)}}, socket}
        end
    end

    def handle_in("on_click_die", %{}, socket) do
      name = socket.assigns[:name]
      game = GameServer.on_click_die(name)
      broadcast!(socket, "update", %{ "game" => Game.client_view(game) })

      # game = Game.clickDie(socket.assigns[:game])
      # socket = assign(socket, :game, game)
      # BackupAgent.put(name, game)
      {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
    end

    def handle_info({:timeoutUpdate, game}, socket) do
      socket = assign(socket, :game, game);
      broadcast!(socket, "timeoutUpdate", %{ "game" => Game.client_view(game) })
      {:noreply, socket}
    end

    # Add authorization logic here as required.
    defp authorized?(_payload) do
      true
    end
  end
