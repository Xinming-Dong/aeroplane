defmodule Aeroplane.GameServer do
    use GenServer

    def reg(name) do
        {:via, Registry, {Aeroplane.GameReg, name}}
    end

    def start(name) do
        spec = %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [name]},
          restart: :permanent,
          type: :worker,
        }
        Aeroplane.GameSup.start_child(spec)
    end

    def start_link(name) do
        game = Aeroplane.BackupAgent.get(name) || Aeroplane.Game.new()
        GenServer.start_link(__MODULE__, game, name: reg(name))
    end

    def handle_call({:peek, _name}, _from, game) do
        {:reply, game, game}
    end

    def peek(name) do
        GenServer.call(reg(name), {:peek, name})
    end

    def init(game) do
        {:ok, game}
    end

    def handle_call({:on_click_die, name}, _from, game) do
        game = Aeroplane.Game.clickDie(game)
        Aeroplane.BackupAgent.put(name, game)
        {:reply, game, game}
    end

    def on_click_die(name) do
        GenServer.call(reg(name), {:on_click_die, name})
    end

    def handle_call({:on_click_piece, name, index}, _from, game) do
        game = Aeroplane.Game.clickPiece(game, index)
        Aeroplane.BackupAgent.put(name, game|>Enum.at(-1))
        {:reply, game, game|>Enum.at(-1)}
    end

    def on_click_piece(name, index) do
        GenServer.call(reg(name), {:on_click_piece, name, index})
    end
end
