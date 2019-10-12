defmodule Aeroplane.Game do
  def new do
    %{
      board: board_init,
      pieceLocation: %{:r => [], :b => [], :y => [], :g => []},
      last2Moved: %{:r => [], :b => [], :y => [], :g =>[]},
      last2Roll: %{:r => [], :b => [], :y => [], :g =>[]},
      player: [:r, :b, :y, :g],
      currPlayer: :r,
      nextPlayer: 0,
      currDie: 6,
      moveablePieces: [], 
     }
  end


  def client_view(game) do
    %{
      currDie: game.currDie,
    }
  end 

  def randomDieNum do
   :rand.uniform(6) 
  end

  # change to next player in player list. 
  # TODO: player number is currently hardcoded
  def switchPlayer(game) do
    next = rem(Enum.find_index(game.player, 
      fn(x) -> x == game.currPlayer end) + 1, 4)
    Enum.at(game.player, next)
  end




  #change nextPlayer
  def handleNextPlayer(game,roll) do
    if roll == 6 do
      game|>Map.put(:nextPlayer, game.currPlayer)
    else 
      game|>Map.put(:nextPlayer, switchPlayer(game))
    end
  end 

  def changeLastRollList(game,roll) do
    [last1 | last2] = game.last2Roll[game.currPlayer]
    newLastRolls = [roll | last1]
    game|>Map.put(:next2Roll, %{game.last2Roll | game.currPlayer => newLastRolls})
  end

  #move back given player's given pieces to the player's camp
  def moveBack(player, pieces) do
  end




  #change moveable list,depends on current player and new roll number
  def changeMoveablePiece(game, roll) do
    [last1 | last2] = game.last2Roll[game.currPlayer]
    cond do
      last1 == 6 && last2 == 6 && roll == 6 ->
      moveBack(game.currPlayer, game.last2Moved[game.currPlayer])
    end
  end



  def clickDie(game) do
    newDieNum = randomDieNum;
    game
    |>handleNextPlayer(newDieNum)
    |>changeMoveablePiece(newDieNum)
    |>changeLastRollList(newDieNum)
  end


  def nextPlayer() do
  end 

  def clickPiece(game, i) do

  end 


  def board_init do
    #camp+start(type 0 and 1)
    %{}
    |>camp_start(:y, 0, 4)|>camp_start(:b, 5, 9)
    |>camp_start(:r, 10,14)|>camp_start(:g,15,19)
    #turning point(type 2)
    |>Map.put(20, [:y, 2]) |>Map.put(33, [:b, 2])
    |>Map.put(46, [:r, 2]) |>Map.put(59, [:g, 2])
    #jumping point(type 3)
    |>Map.put(27, [:g, 3]) |>Map.put(40, [:y, 3])
    |>Map.put(53, [:b, 3]) |>Map.put(66, [:r, 3])
    #bridge
    |>bridge(:y, 72, 77) |>bridge(:b, 78, 83)
    |>bridge(:r, 84, 89) |>bridge(:g, 90, 95)
    #normal
    |>normal(21, 71)
  end

  def normal(map, s, e) when s > e do
    map
  end
  
  def normal(map, s, e) do
    newmap = if !Map.has_key?(map, s) do
      cond do
        rem(s, 4) == 0 ->
          Map.put(map, s, [:y, 5])
        rem(s, 4) == 1 ->
          Map.put(map, s, [:b, 5])
        rem(s, 4) == 2 ->
          Map.put(map, s, [:r, 5])
        true ->
          Map.put(map, s, [:g, 5])
      end
    else
      map
    end 
    normal(newmap, s + 1, e)
  end

  def bridge(map,color, s, e) when s <= e do
    map|>Map.put(s, [color, 4])
       |>bridge(color, s + 1, e)
  end 

  def bridge(map, color, s, e) when s > e do
    map
  end 

  def camp_start(map, color, s, e) when s < e do
    map|>Map.put(s, [color, 0])
       |>camp_start(color, s + 1, e)
  end

  def camp_start(map, color, s, e) when s == e do
    map|>Map.put(s, [color, 1])
  end
end
