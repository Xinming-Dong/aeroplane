defmodule Aeroplane.Game do
  def new do
    # TODO: default starting color is now yellow
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
      moveablePieces: [:y],
      dieActive: 1
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
    if game.dieActive == 0 do
      game
    else
      newDieNum = randomDieNum;
      game
      |>Map.put(:currDie, newDieNum)
      |>handleNextPlayer(newDieNum)
      |>changeMoveablePiece(newDieNum)
      |>changeLastRollList(newDieNum)
      |>Map.put(:dieActive, 0)
    end
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
    newLastRolls = [roll, last1]
    game|>Map.put(:last2Roll, game.last2Roll|>Map.put(game.currPlayer,newLastRolls))
  end



  #move back given player's given pieces to the player's camp
  #TODO didn't test
  def moveBack(game) do
    campbase = game.palyer[game.currPlayer] * 5
    currLocations = game.pieceLocation[game.currPlayer]
                   |> Enum.with_index()
                   |> Enum.map(fn {pos, pieceID} -> 
                     (if Enum.member?(game.last2Moved[game.currPlayer], pieceID) do
                       campbase + pieceID
                     else
                       pos
                     end) end)
    game |>Map.put(:peiceLocation, game.pieceLocation |> Map.put(game.currPlayer, currLocations))
  end




  #change moveable list,depends on current player and new roll number
  def changeMoveablePiece(game, roll) do
    [last1 | last2] = game.last2Roll[game.currPlayer]
    cond do
      last1 == 6 && last2 == 6 && roll == 6 ->
        game |> moveBack() 
        |>Map.put(:moveablePieces, [game.currPlayer])
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
    |> Enum.map(fn x -> Enum.find_index(game.pieceLocation[game.currPlayer], fn y -> y == x end) end)
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
    i = i - game.player[iColor] * 4
    result = if !moveable(game, i, iColor) do
      game
    else
      game
      |>moveClickedPiece(i, iColor)
      |>jumpClickedPiece(i, iColor)
      |>storeLastMove(i, iColor)
      |>resetMoveable()
      |>changePlayer()
      |>Map.put(:dieActive, 1)
    end 

  end


  #set moveable to empty list
  def resetMoveable(game) do
    game |> Map.put(:moveablePieces, [game.currPlayer])
  end

  # change curr player to nextPlayer
  def changePlayer(game) do
    game |> Map.put(:currPlayer, game.nextPlayer)
    |> Map.put(:nextPlayer, 0)
  end

  #store the just clicked piece
  def storeLastMove(game, i, iColor) do
    [last1 | last2] = game.last2Moved[iColor]
    game |> Map.put(:last2Moved, game.last2Moved |> Map.put(iColor, [i, last1]))
  end


  #move without jumping
  def moveClickedPiece(game, i, color) do
    currLocation = game.pieceLocation[color]|>Enum.at(i)
    newLocation = cond do
      game.board[currLocation]|>Enum.at(1) == 0 ->
        game.player[color] * 5 + 4
      game.board[currLocation]|>Enum.at(1) == 1 ->
        22 + 13 * game.player[color] + game.currDie
      game.board[currLocation]|>Enum.at(1) == 2 && game.board[currLocation]|>Enum.at(0) == color->
        71 + 6 * game.palyer[color] + game.currDie
      game.board[currLocation]|>Enum.at(1) == 4 ->
        [77 + game.player[color] * 6, currLocation + game.currDie]|>Enum.min()
      true ->
        moveWithinBoundary(game, color, currLocation)
    end
    newLocationList = game.pieceLocation[color] |> List.replace_at(i, newLocation)
    game |> Map.put(:pieceLocation, game.pieceLocation |> Map.put(color, newLocationList))
  end


  def moveWithinBoundary(game, color, currLocation) do
    tempLocation = if currLocation + game.currDie > 71 do
      rem(currLocation + game.currDie, 72) + 20
    else
      currLocation + game.currDie
    end

    cond do
      color == :y ->
        if currLocation > 20 && tempLocation < 20 do
            currLocation + game.currDie  - 1  
        else 
            tempLocation
       end
     color == :b ->
        if currLocation < 33 && tempLocation > 33 do
          game.currDie - 33 + currLocation + 77
        else 
          tempLocation
        end
     color == :r ->
        if currLocation < 46 && tempLocation > 46 do
          game.currDie - 46 + currLocation + 83
        else 
          tempLocation
        end
     color == :g ->
        if currLocation < 59 && tempLocation > 59 do
          game.currDie - 59 + currLocation + 89
        else 
          tempLocation
        end
    end
  end


  
  def jumpClickedPiece(game, i, color) do
    currLocation = game.pieceLocation[color]|>Enum.at(i)
    locationInfo = game.board[currLocation]
    newLocation = cond do
      locationInfo|>Enum.at(0) == color &&
        locationInfo|>Enum.at(1) == 3 ->
        if currLocation + 12 > 71 do
          rem(currLocation + 12, 72) + 20
        else
          currLocation + 12
        end
      locationInfo |>Enum.at(0) == color ->
        if currLocation + 4 > 71 do
          rem(currLocation + 4, 72) + 20
        else 
          currLocation + 4
        end
      true ->
        currLocation
    end
  end

  #check if clicked piece is moveable
  def moveable(game, i, color) do
    cond do
      Enum.count(game.moveablePieces) <= 1 ->
        false
      Enum.at(game.moveablePieces, 0) != color ->
        false
      !Enum.member?(game.moveablePieces, i) ->
        false
      true ->
        true
    end
  end


  ####################### create board with attributes################################
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
