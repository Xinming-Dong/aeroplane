defmodule Aeroplane.Game do
  def new do
    %{
      board: board_init,
      pieceLocation: %{:r => [10, 11, 12, 13], :b => [5, 6, 7, 8], 
                       :y => [0, 1, 2, 3], :g => [15, 16, 17, 18]},
      last2Moved: %{:r => [-1, -1], :b => [-1, -1], :y => [-1, -1], :g =>[-1, -1]},
      last2Roll: %{:r => [-1, -1], :b => [-1, -1], :y => [-1, -1], :g =>[-1, -1]},
      player: [y: 0, b: 1, r: 2, g: 3],
      currPlayer: :y,
      nextPlayer: 0,
      currDie: 6,
      moveablePieces: [],
     }
  end


  # TODO
  def client_view(game) do
    %{
      currDie: game.currDie,
    }
  end 

  ##################clickDie########################
  def clickDie(game) do
    newDieNum = randomDieNum;
    game
    |>Map.put(:currDie, newDieNum)
    |>handleNextPlayer(newDieNum)
    |>changeMoveablePiece(newDieNum)
    |>changeLastRollList(newDieNum)
  end

  def randomDieNum do
   :rand.uniform(6) 
  end

  #change next Player
  def handleNextPlayer(game,roll) do
    if roll == 6 do
      game|>Map.put(:nextPlayer, game.currPlayer)
    else 
      game|>Map.put(:nextPlayer, switchPlayer(game))
    end
  end 


  # change to next player in player list. 
  # TODO: player number is currently hardcoded
  def switchPlayer(game) do
    next = rem(game.player[game.currPlayer] + 1, 4)
    game.player|>Enum.find(fn {k, v} -> v == next end)|>elem(0)
  end



  #add current roll to the front of the list
  def changeLastRollList(game,roll) do
    [last1 | last2] = game.last2Roll[game.currPlayer]
    newLastRolls = [roll | last1]
    game|>Map.put(:last2Roll, game.last2Roll|>Map.put(game.currPlayer,newLastRolls))
  end



  #move back given player's given pieces to the player's camp
  def moveBack(game) do
    campbase = game.palyer[game.currPlayer] * 5
    currLocation = game.pieceLocation[game.currPlayer]
                   |> Enum.with_index()
                   |> Enum.map(fn {pos, pieceID} -> 
                     (if Enum.member?(game.last2Moved[game.currPlayer], pieceID) do
                       campbase + pieceID
                     else
                       pos
                     end) end)
  end




  #change moveable list,depends on current player and new roll number
  def changeMoveablePiece(game, roll) do
    [last1 | last2] = game.last2Roll[game.currPlayer]
    cond do
      last1 == 6 && last2 == 6 && roll == 6 ->
        moveBack(game)
        Map.put(game, :moveablePieces, [game.currPlayer])
      last2 != 6 && roll == 6 ->
        Map.put(game, :moveablePieces, [game.currPlayer, 0, 1, 2, 3])
      roll != 6 ->
        Map.put(game, :moveablePieces, [game.currPlayer] ++ piecesNotInCamp(game))

    end
  end

  # return the ID of all pieces that are not in camp for current player
  def piecesNotInCamp(game) do
    campStart = game.player[game.currPlayer] * 5 
    game.pieceLocation[game.currPlayer]|> Enum.filter(fn x -> x > campStart + 3 end)
    |> Enum.map(fn x -> Enum.find_index(game.pieceLocation, x) end)
  end

  ###############clickPiece#########################################

  def clickPiece(game, i) do
    pieceIDmin = game.player[game.currPlayer] * 4
    iColor = cond do
      0 <= i && i <= 3 ->
        :y
      4<=i && i<= 7 ->
        :b
      8<=i && i<=11 ->
        :r
      12<=i && i<= 15 ->
        :g
    end
    i = i - game.player[icolor] * 4
    result = if i < pieceIDmin || i > pieceIDmin + 3 || !moveable(game, i) do
      game
    else
      moveClickedPiece(game, i, icolor)
      
    end 

  end

  def moveClickedPiece(game, i) do
  
  end



  def moveable(game, i, color) do
    result = cond do
      Enum.count(game.moveablePieces) == 1 ->
        false
      Enum.at(game.moveablePieces, 0) != color ->
        false
      !Enum.member?(game.moveablePieces, i) ->
        false
      true ->
        true
    end
  end


  # create board with attributes################################
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

  ###############################################################

end
