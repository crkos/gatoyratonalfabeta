Cell[][] grid;
int cols = 3;
int rows = 3;

Player player1 = new Player(color(255, 0, 0), "Jugador");
Player player2 = new Player(color(0, 255, 0), "BOT");
Player currentPlayer = player1;

void setup() {
  size(500, 500);
  grid = new Cell[cols][rows];
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j] = new Cell(i * 166.6, j * 166.6, 166.6, 166.6);
    }
  }
}

void draw() {
  background(0);
  frameRate(12);
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j].display();
      grid[i][j].drawShape();
    }
  }
  Player[] players = {player1, player2};
  boolean winner = false;
  boolean player1Winner = false, player2Winner = false;

  if (isWinner(player1)) {
    player1Winner = true;
    winner = true;
  } else if (isWinner(player2)) {
    player2Winner = true;
    winner = true;
  }
  if (winner) {
    String result = "The winner is: ";
    if (player1Winner) {
      result += "Humano";
    } else if (player2Winner) {
      result += "BOT";
    }
    textSize(32);
    fill(255, 255, 0);
    text(result, width/2-textWidth(result)/2, height/2-16);
    noLoop();
  } else if (filledCells == 9) {
    String result = "Draw!";
    textSize(32);
    fill(255, 255, 0);
    text(result, width/2-textWidth(result)/2, height/2-16);
    noLoop();
  } else if (currentPlayer == player2) {
    // Bot's turn
    int bestMove = minimaxAlphaBeta(0, player2, Integer.MIN_VALUE, Integer.MAX_VALUE);
    int bestMoveX = bestMove % 3;
    int bestMoveY = bestMove / 3;
    grid[bestMoveX][bestMoveY].filledBy = player2;
    filledCells++;
    currentPlayer = player1; // Switch back to player1
  }
}

boolean isWinner(Player player) {
  // Check rows
  for (int i = 0; i < rows; i++) {
    if (grid[0][i].filledBy == player && grid[1][i].filledBy == player && grid[2][i].filledBy == player) {
      return true;
    }
  }

  // Check columns
  for (int i = 0; i < cols; i++) {
    if (grid[i][0].filledBy == player && grid[i][1].filledBy == player && grid[i][2].filledBy == player) {
      return true;
    }
  }

  // Check diagonal 1
  if (grid[0][0].filledBy == player && grid[1][1].filledBy == player && grid[2][2].filledBy == player) {
    return true;
  }

  // Check diagonal 2
  if (grid[0][2].filledBy == player && grid[1][1].filledBy == player && grid[2][0].filledBy == player) {
    return true;
  }

  return false;
}

int filledCells = 0;

void mousePressed() {
  if (filledCells == 9) {
    println("Game over! All cells are filled.");
    return;
  }

  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (mouseX >= grid[i][j].x && mouseX <= grid[i][j].x + grid[i][j].w &&
          mouseY >= grid[i][j].y && mouseY <= grid[i][j].y + grid[i][j].h) {
        if (grid[i][j].filledBy == null) {
          grid[i][j].filledBy = player1;
          filledCells++;
          if (filledCells == 9) {
            println("Game over! All cells are filled.");
            return;
          }

          currentPlayer = player2; // Switch to bot's turn
        }
      }
    }
  }
}

int minimaxAlphaBeta(int depth, Player player, int alpha, int beta) {
  if (isWinner(player1)) {
    // Player1 wins
    return -10;
  } else if (isWinner(player2)) {
    // Player2 (bot) wins
    return 10;
  } else if (filledCells == 9) {
    // It's a draw
    return 0;
  }

  int bestScore;
  int bestMove = -1;

  if (player == player2) {
    bestScore = Integer.MIN_VALUE;
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        if (grid[i][j].filledBy == null) {
          // Make a move for the bot
          grid[i][j].filledBy = player2;
          filledCells++;

          // Recursively call minimaxAlphaBeta for the opponent (player1)
          int score = minimaxAlphaBeta(depth + 1, player1, alpha, beta);

          // Undo the move
          grid[i][j].filledBy = null;
          filledCells--;

          // Update the best score and move if necessary
          if (score > bestScore) {
            bestScore = score;
            bestMove = i + j * 3;
          }

          // Perform alpha-beta pruning
          alpha = max(alpha, bestScore);
          if (beta <= alpha) {
            break;
          }
        }
      }
    }
  } else {
    bestScore = Integer.MAX_VALUE;
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        if (grid[i][j].filledBy == null) {
          // Make a move for player1
          grid[i][j].filledBy = player1;
          filledCells++;

          // Recursively call minimaxAlphaBeta for the opponent (bot)
          int score = minimaxAlphaBeta(depth + 1, player2, alpha, beta);

          // Undo the move
          grid[i][j].filledBy = null;
          filledCells--;

          // Update the best score and move if necessary
          if (score < bestScore) {
            bestScore = score;
            bestMove = i + j * 3;
          }

          // Perform alpha-beta pruning
          beta = min(beta, bestScore);
          if (beta <= alpha) {
            break;
          }
        }
      }
    }
  }

  if (depth == 0) {
    return bestMove;
  } else {
    return bestScore;
  }
}

class Cell {
  float x, y, w, h;
  Player filledBy;

  Cell(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    filledBy = null;
  }

  void display() {
    stroke(255);
    noFill();
    rect(x, y, w, h);
  }

  void drawShape() {
    if (filledBy == player1) {
      // Draw "X"
      float padding = w * 0.2;
      line(x + padding, y + padding, x + w - padding, y + h - padding);
      line(x + padding, y + h - padding, x + w - padding, y + padding);
    } else if (filledBy == player2) {
      // Draw "O"
      float r = w * 0.4;
      float centerX = x + w/2;
      float centerY = y + h/2;
      ellipse(centerX, centerY, r, r);
    }
  }
}

class Player {
  color fillColor;
  String name;

  Player(color fillColor, String name) {
    this.fillColor = fillColor;
    this.name = name;
  }
}
