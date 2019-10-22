defmodule AeroplaneWeb.GamesChannel do
    use AeroplaneWeb, :channel
    alias Aeroplane.Game
    alias Aeroplane.BackupAgent

    def join("games:" <> name, payload, socket) do
      if authorized?(payload) do
        game = BackupAgent.get(name) || Game.new()
        BackupAgent.put(name, game)
        # game = Game.new()
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
        case Game.clickPiece(socket.assigns[:game], ii) do
          [st1, st2, st3] ->
            socket = assign(socket, :game, st1)
            BackupAgent.put(name, st3)
            Process.send_after(self(), {:update, st2}, 300)
            Process.send_after(self(), {:update, st3}, 600)
            {:reply, {:ok, %{ "game" => Game.client_view(st1)}}, socket}
          [st1, st2] ->
            socket = assign(socket, :game, st1);
            BackupAgent.put(name, st2)
            Process.send_after(self(), {:update, st2}, 300)
            {:reply, {:ok, %{ "game" => Game.client_view(st1)}}, socket}
          st1 ->
            socket = assign(socket, :game, st1)
            BackupAgent.put(name, st1)
            {:reply, {:ok, %{ "game" => Game.client_view(st1)}}, socket}
        end
    end

    def handle_in("on_click_die", %{}, socket) do
      name = socket.assigns[:name]
      game = Game.clickDie(socket.assigns[:game])
      socket = assign(socket, :game, game)
      BackupAgent.put(name, game)
      {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
    end

    def handle_info({:update, game}, socket) do
      socket = assign(socket, :game, game);
      push(socket, "update", %{"game" => Game.client_view(game)})
      {:noreply, socket}
    end

    # Add authorization logic here as required.
    defp authorized?(_payload) do
      true
    end
  end
