defmodule AeroplaneWeb.GamesChannel do
    use AeroplaneWeb, :channel
    alias Aeroplane.Game
    alias Aeroplane.BackupAgent
    alias Aeroplane.GameServer

    def join("games:" <> name, payload, socket) do
      # IO.puts "payload"
      # IO.inspect payload

      if authorized?(payload) do
        GameServer.start(name)
        game = GameServer.peek(name)
        game = GameServer.add(name, payload)

        BackupAgent.put(name, game)
        socket = socket
        |> assign(:name, name)
        |> assign(:user, payload)
        {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
      else
        {:error, %{reason: "unauthorized"}}
      end
    end

    def handle_in("on_click_piece", %{"index" => ii}, socket) do
        name = socket.assigns[:name]
        user = socket.assigns[:user]
        game = GameServer.on_click_piece(name, user, ii)
        case game do
          [st1, st2, st3] ->
            broadcast!(socket, "update", %{ "game" => Game.client_view(st1) })
            Process.send_after(self(), {:update, st2}, 800)
            Process.send_after(self(), {:update, st3}, 1600)
            {:reply, {:ok, %{ "game" => Game.client_view(st1)}}, socket}
          [st1, st2] ->
            broadcast!(socket, "update", %{ "game" => Game.client_view(st1) })
            Process.send_after(self(), {:update, st2}, 800)
            {:reply, {:ok, %{ "game" => Game.client_view(st1)}}, socket}
          st1 ->
            broadcast!(socket, "update", %{ "game" => Game.client_view(st1) })
            {:reply, {:ok, %{ "game" => Game.client_view(st1)}}, socket}
        end
    end

    def handle_in("on_click_die", %{}, socket) do
      IO.inspect socket
      name = socket.assigns[:name]
      user = socket.assigns[:user]
      game = GameServer.on_click_die(name, user)
      broadcast!(socket, "update", %{ "game" => Game.client_view(game) })
      {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
    end

    def handle_info({:update, game}, socket) do
      broadcast!(socket, "update", %{ "game" => Game.client_view(game) })
      {:noreply, socket}
    end

    # Add authorization logic here as required.
    defp authorized?(_payload) do
      true
    end
  end

