defmodule Aeroplane.Game do
  def new do
    # TODO: default starting color is now yellow
    %{
      board: board_init(),
      pieceLocation: %{:r => [10, 11, 12, 13], :b => [5, 6, 7, 8],
                       :y => [0, 1, 2, 3], :g => [15, 16, 17, 18]},
      last2Moved: %{:r => [-1, -1], :b => [-1, -1], :y => [-1, -1], :g =>[-1, -1]},
      last2Roll: %{:r => [-1, -1], :b => [-1, -1], :y => [-1, -1], :g =>[-1, -1]},
      player: [y: 0, b: 1, r: 2, g: 3],
      currPlayer: :y,
      nextPlayer: 0,
      currDie: 0,
      moveablePieces: [:y],
      dieActive: 1,
      winner: ""
     }
  end


  # TODO
  def client_view(game) do
    %{
      die: game.currDie,
      pieces_loc: pieceLocToCoor(game.pieceLocation, board_coor()),
      curr_player: getCurrPlayer(game.currPlayer),
      winner: game.winner
    }
  end

  def getCurrPlayer(player) do
    cond do
      player == :y ->
        "yellow"
      player == :b ->
        "blue"
      player == :r ->
        "red"
      player == :g ->
        "green"
    end
  end

  def pieceLocToCoor(location, coor) do
    List.flatten([location[:y] | [location[:b] | [location[:r] | location[:g]]]])
    |>Enum.map(fn x -> coor[x] end)
  end

  ##################clickDie########################
  def clickDie(game) do
    game = if game.dieActive == 0 do
      game
    else
      newDieNum = randomDieNum(game);
      game
      |>Map.put(:currDie, newDieNum)
      |>handleNextPlayer(newDieNum)
      |>changeMoveablePiece(newDieNum)
      |>changeLastRollList(newDieNum)
    end
    if Enum.count(game.moveablePieces) <= 1 do
      game |>Map.put(:currPlayer, game.nextPlayer)
      |>Map.put(:dieActive, 1)
    else
      game|>Map.put(:dieActive, 0)
    end
  end

  def randomDieNum(game) do
    if piecesNotInCamp(game)|>Enum.count() == 0 do
      Enum.random([1,2,3,4,5,6,6,6])
    else
      :rand.uniform(6)
    end
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
    game.player|>Enum.find(fn {_k, v} -> v == next end)|>elem(0)
  end



  #add current roll to the front of the list
  def changeLastRollList(game,roll) do
    [last1 | _last2] = game.last2Roll[game.currPlayer]
    newLastRolls = [roll, last1]
    game|>Map.put(:last2Roll, game.last2Roll|>Map.put(game.currPlayer,newLastRolls))
  end



  #move back given player's given pieces to the player's camp
  def moveBack(game) do
    campbase = game.player[game.currPlayer] * 5
    currLocations = game.pieceLocation[game.currPlayer]
                   |> Enum.with_index()
                   |> Enum.map(fn {pos, pieceID} ->
                     (if Enum.member?(game.last2Moved[game.currPlayer], pieceID) do
                       campbase + pieceID
                     else
                       pos
                     end) end)
    game |>Map.put(:pieceLocation, game.pieceLocation |> Map.put(game.currPlayer, currLocations))
  end




  #change moveable list,depends on current player and new roll number
  def changeMoveablePiece(game, roll) do
    [last1 | last2] = game.last2Roll[game.currPlayer]
    last2 = Enum.at(last2, 0)
    cond do
      last1 == 6 && last2 == 6 && roll == 6 ->
        game |> moveBack()
        |>Map.put(:moveablePieces, [game.currPlayer])
      roll == 6 ->
        Map.put(game, :moveablePieces, [game.currPlayer] ++ withoutAtDes(game.currPlayer, [0, 1, 2, 3], game.pieceLocation[game.currPlayer]))
      roll != 6 ->
        Map.put(game, :moveablePieces, [game.currPlayer] ++ withoutAtDes(game.currPlayer, piecesNotInCamp(game), game.pieceLocation[game.currPlayer]))

    end
  end

  #exclude the id of the piece that are already at the destination
  def withoutAtDes(player, list, location) do
    des = cond do
      player == :y -> 77
      player == :b -> 83
      player == :r -> 89
      player == :g -> 95
    end
    list|>Enum.filter(fn x -> Enum.at(location, x)!= des end)
  end

  # return the ID of all pieces that are not in camp for current player
  def piecesNotInCamp(game) do
    campStart = game.player[game.currPlayer] * 5
    result = game.pieceLocation[game.currPlayer]|> Enum.filter(fn x -> x > campStart + 3 end)
    |> Enum.map(fn x -> Enum.find_index(game.pieceLocation[game.currPlayer], fn y -> y == x end) end)
    result
  end

  ###############clickPiece#########################################

  def clickPiece(game, i) do
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
    if !moveable(game, i, iColor) do
      game
    else
      st1 = game
      |>moveClickedPiece(i, iColor)
      st2 = st1
      |>jumpClickedPiece(i, iColor)
      st3 = st2
      |> moreJump(i, iColor)
      cond do
        st1 == st2 && st2 == st3 ->
          st1|> afterMovePiece(i, iColor)
        st1 != st2 && st2 == st3 ->
          st2 = st2 |>afterMovePiece(i, iColor)
          [st1, st2]
        st1 != st2 && st2 != st3 ->
          st3 = st3|>afterMovePiece(i, iColor)
          [st1, st2, st3]
      end
    end
  end

  def afterMovePiece(game, i, iColor) do
    IO.puts("here")
    game = game
    |>pieceFight(i, iColor)
    |>storeLastMove(i, iColor)
    |>resetMoveable()
    |>changePlayer()
    winner = getWinner(game.pieceLocation)
    if winner !=  0 do
      game|>Map.put(:winner, winner)
    else
      game|>Map.put(:dieActive, 1)
    end
  end


  #return 0 if game is not over, otherwise return winner
  def getWinner(loc) do
    cond do
      loc[:y]|>Enum.count(fn x -> x == 77 end) == 4 ->
        "Yellow"
      loc[:b]|>Enum.count(fn x -> x == 83 end) == 4 ->
        "Blue"
      loc[:r]|>Enum.count(fn x -> x == 89 end) == 4 ->
        "Red"
      loc[:g]|>Enum.count(fn x -> x == 95 end) == 4->
        "Green"
      true ->
        0
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
  def storeLastMove(game, i, color) do
    [last1 | _last2] = game.last2Moved[color]
    game |> Map.put(:last2Moved, game.last2Moved |> Map.put(color, [i, last1]))
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
        71 + 6 * game.player[color] + game.currDie
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
        if currLocation > 65 && tempLocation < 26 do
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
      locationInfo |>Enum.at(0) == color &&
        locationInfo|>Enum.at(1) == 5->
        if currLocation + 4 > 71 do
          rem(currLocation + 4, 72) + 20
        else
          currLocation + 4
        end
      true ->
        currLocation
    end
    game |>Map.put(:pieceLocation, game.pieceLocation
    |> Map.put(color, game.pieceLocation[color] |> List.replace_at(i, newLocation)))
  end

  #jump the second time when land on big jump after first jump.
  def moreJump(game, i, color) do
    loc = game.pieceLocation[color]|>Enum.at(i)
    newLoc = if game.board[loc]|>Enum.at(1) == 3
    && game.board[loc] |>Enum.at(0) == color do
      if loc + 12 > 71 do
        rem(loc + 12, 72) + 20
      else
        loc + 12
      end
    else
      loc
    end
    game |>Map.put(:pieceLocation, game.pieceLocation
    |> Map.put(color, game.pieceLocation[color] |> List.replace_at(i, newLoc)))
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



  #if end up on other piece, send that piece back to camp
  #TODO: didn't test
  def pieceFight(game, i, color) do
    newLocation = game.pieceLocation[color]|>Enum.at(i)
    location = game.pieceLocation
    previousLoc = List.flatten([location[:y] | [location[:b] | [location[:r] | location[:g]]]])
    |>List.replace_at(i, -1)
    if Enum.member?(previousLoc, newLocation) do
      prevI = Enum.find_index(previousLoc, fn x -> x == newLocation end)
      prevColor = game.player|>Enum.find(fn {_k, v} -> v == div(prevI, 4) end)|>elem(0)
      if prevColor != color do
        cond do
          prevI <= 3 ->
            game|>Map.put(:pieceLocation, game.pieceLocation |> Map.put(:y, game.pieceLocation[:y]|>List.replace_at(prevI, prevI)))
          prevI <= 7 ->
            game|>Map.put(:pieceLocation, game.pieceLocation |> Map.put(:b, game.pieceLocation[:b]|>List.replace_at(prevI - 4, prevI + 1)))
          prevI <= 11 ->
            game|>Map.put(:pieceLocation, game.pieceLocation |> Map.put(:r, game.pieceLocation[:r]|>List.replace_at(prevI - 8, prevI + 2)))
          prevI <= 15 ->
            game|>Map.put(:pieceLocation, game.pieceLocation |> Map.put(:g, game.pieceLocation[:g]|>List.replace_at(prevI - 12, prevI + 3)))
        end
      else
        game
      end
    else
      game
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

  def bridge(map, _color, s, e) when s > e do
    map
  end

  def camp_start(map, color, s, e) when s < e do
    map|>Map.put(s, [color, 0])
       |>camp_start(color, s + 1, e)
  end

  def camp_start(map, color, s, e) when s == e do
    map|>Map.put(s, [color, 1])
  end

  ###################Create board with coordinates#################################
  def board_coor do
    %{} #camp
    |>camp_coor()
    |>start_coor()
    |>bridge_coor()
    |>normal_square()
    |>triangles()
  end



  ###########normal square################
  def normal_square(map) do
    map
    |>continuousSquare_helper(22, 19, 196, 426, -1, :v, normal_interval())
    |>continuousSquare_helper(71, 69, 196, 548, -1, :v, normal_interval())
    |>continuousSquare_helper(44, 49, 817, 426, 1, :v, normal_interval())
    |>continuousSquare_helper(29, 27, 360, 256, -1, :v, normal_interval())
    |>continuousSquare_helper(64, 62, 360, 715, -1, :v, normal_interval())
    |>continuousSquare_helper(37, 39, 654, 256, 1, :v, normal_interval())
    |>continuousSquare_helper(54, 56, 654, 715, 1, :v, normal_interval())
    |>continuousSquare_helper(31, 36, 423, 198, 1, :h, normal_interval())
    |>continuousSquare_helper(61, 56, 423, 817, -1, :h, normal_interval())
    |>continuousSquare_helper(24, 26, 256, 362, 1, :h, normal_interval())
    |>continuousSquare_helper(41, 43, 716, 362, 1, :h, normal_interval())
    |>continuousSquare_helper(68, 66, 256, 652, -1, :h, normal_interval())
    |>continuousSquare_helper(51, 49, 716, 651, -1, :h, normal_interval())
  end

  def normal_interval do
    41
  end

  ##################triangles###############################
  def triangles(map) do
    map
    |>triangles_v(23, 3, 17, 213, 382)
    |>triangles_v(69, -3, -17, 213, 634)
    |>triangles_h()
  end

  def triangles_v(map,s, acc1, acc2, s_x, s_y) do
    map
    |>continuousSquare_helper(s, s+2*acc1, s_x, s_y, acc1, :h, tra_inter_small())
    |>continuousSquare_helper(s+acc2, s + acc2 + 2*acc1, s_x + tra_inter_big(), s_y, acc1, :h, tra_inter_small())
  end

  def triangles_h(map) do
    map
    |>continuousSquare_helper(30, 24, 379, 212, -3, :v, tra_inter_small())
    |>continuousSquare_helper(65, 59, 379, 212 + tra_inter_big(), -3, :v, tra_inter_small())
    |>continuousSquare_helper(36, 42, 635, 212, 3, :v, tra_inter_small())
    |>continuousSquare_helper(53, 59, 635, 212 + tra_inter_big(), 3, :v, tra_inter_small())
  end


  def tra_inter_small do
    129
  end
  def tra_inter_big do
    459
  end

  ############bridge###############
  def bridge_interval do
    41
  end

  def bridge_coor(map) do
    map|>continuousSquare_helper(72, 78, 256, 507, 1, :h, bridge_interval())
    |>continuousSquare_helper(89, 83, 550, 507, -1, :h, bridge_interval())
    |>continuousSquare_helper(78, 84, 507, 256, 1, :v, bridge_interval())
    |>continuousSquare_helper(95, 89, 507, 550, -1, :v, bridge_interval())
  end

  def continuousSquare_helper(map, s, e, s_x, s_y, acc, direction, interval) when s != e do
    if direction == :h do
      map|>Map.put(s, %{x: s_x, y: s_y})
      |>continuousSquare_helper(s + acc, e, s_x + interval, s_y, acc, direction, interval)
    else
      map |>Map.put(s, %{x: s_x, y: s_y})
      |>continuousSquare_helper(s + acc, e, s_x, s_y + interval, acc, direction, interval)
    end
  end

  def continuousSquare_helper(map, s, e, _s_x, _s_y, _acc, _direction, _interval) when s == e do
    map
  end
  ###########start###############
  def start_coor(map) do
    map|>Map.put(4, %{x: 153, y: 350})
    |>Map.put(9, %{x: 663, y: 156})
    |>Map.put(14, %{x: 860, y: 666})
    |>Map.put(19, %{x: 348, y: 861})
  end
  #######Camp###################
  def camp_interval_small do
    64
  end

  def camp_interval_big do
    554
  end

  def camp_coor_s do
    198
  end


  def camp_coor_color(map, s, sx, sy) do
    map|>Map.put(s, %{x: sx, y: sy}) |>Map.put(s + 1, %{x: sx + camp_interval_small(), y: sy})
    |>Map.put(s + 2, %{x: sx, y: sy + camp_interval_small()})
    |> Map.put(s + 3, %{x: sx + camp_interval_small(), y: sy + camp_interval_small()})
  end

  def camp_coor(map) do
    map|>camp_coor_color(0, camp_coor_s(), camp_coor_s())
    |>camp_coor_color(5, camp_coor_s() + camp_interval_big(), camp_coor_s())
    |>camp_coor_color(15, camp_coor_s(), camp_coor_s() + camp_interval_big())
    |>camp_coor_color(10, camp_coor_s() + camp_interval_big(), camp_coor_s() + camp_interval_big())
  end

  ######################################################################################
end
