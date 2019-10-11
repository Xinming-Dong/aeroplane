## Concept document of Multi-player Areaplen Chess web application
### Authors: Xinming Dong, Weihan Liu

- What game are you going to build?
  <p>
  We are going to build a board game called aeroplane chess. This is a tradi
tional board game which is popular in China. As a Chinese, this is one 
of the best childhood memory to me. The game is similar to the western game of 
Ludo but using airplane feature as pieces.
  </p> 
  <p>This game has a required and fixed game board with 52 spaces filling the 
board in a circle shape. It can be played by at least two players and at most 
four players. Each player chooses their own color from green, blue, red and 
yellow, and start the game from the corner of their chosen color with four 
pieces. Basic rule is that each player takes turns to roll a die and move their 
pieces accordingly. Whoever move all his/her four pieces to the ending point 
win the game. There are more detailed rules that bring the interaction between 
players and add fun to this game, and these rules will be illustrated below.
  </p> 

- Is the game well specified?
  <p>This game has well specified rules:</p>
  <p>Player can only “launch” their “airplanes” by rolling at 6. If you already 
have at least one “launched” piece but did not launch all the pieces, you can 
choose to launch another piece or take one additional roll if you roll a 6.</p> 
  <p>hen a piece lands on the space with the same color of itself, it can jump 
to the next space with this color, which is 4 spaces closer to the ending point.
  </p> 
  <p>
  If one of your piece lands on the opponent’s piece, you can “shoot down” 
this piece which sends the opponent’s piece back to the starting camp. Like o
ther un-launched piece, this piece will need to wait for another “6” to launch.
  </p>
  <p> 
  There are additional shortcut squares on the game board, and each color only 
has one of this shortcut square. If your piece lands on this square, you can 
jump 12 spaces. </p>
  <p>
  There might be some variance regarding the specific rules, for example, some 
version of the game allows a launch on a roll of 5 or 6. However, these rules 
are based on our own childhood memory, and it’s the combination of the version 
we played. We set up these rules after a discussion.</p>

- Game Functionality that may be Cut:
 1. Home Zone Backtrack Rule
  <p>If a player cannot move pieces into the center base by an exact roll of 
the die, then they must move their piece backwards according to number rolled. 
We will firstly allow a piece to reach the center with any rolling number that 
larger than the number of remaining steps.</p>
  2. 3D dice
  <p>Generally speaking, players will get more excitement with a 3D dice that 
can roll with a click. However, drawing a rolling dice may cost us much time, 
so we will currently use a button that gives a random number instead of the 
dice.</p>

- Challenges
  1. Remembering previous moves
  <p>In this game, players should move their previous 2 pieces that moved by 
their 6s back with a third 6 coming out. Therefore, keeping record of a user’s 
previous moves is an issue.</p>  
  2. Representing Chessboard
  <p>Aeroplane does not have a regular chessboard shape. It looks like grid 
chessboard, but is more complex than traditional chessboard. For example, the 
hangar and the center should hold four pieces, while others should hold one. 
Moreover, there are spaces that not hold pieces. This makes it difficult to 
choose a data structure to represent the game states in the chessboard.i</p>
