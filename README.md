# Moriarty Chess Engine

Moriarty is a powerful and cunning chess engine, inspired by the greatest arch-nemesis of Sherlock Holmes. This Flutter-based application features an interactive chessboard and unique UI elements to provide an engaging chess-playing experience.

<p align="center">
  <img src="https://github.com/xajxatel/moriarty_chess_engine/assets/137952206/ac1ba677-783c-4dc0-a369-775a5b5e8816" alt="mor2" height="500">
</p>

## Features

- **Intelligent AI**: Play against Moriarty, who calculates every move with precision.
- **Interactive Chessboard**: Tap and move pieces with a responsive and intuitive interface.
- **Haptic Feedback**: Feel each move with subtle vibrations.

<p align="center">
  <img src="https://github.com/xajxatel/moriarty_chess_engine/assets/137952206/de9d88d1-f93a-4232-a019-69fb5781e044" alt="Game Screen 1" height="600">
  <img src="https://github.com/xajxatel/moriarty_chess_engine/assets/137952206/cd381f18-172e-474c-8e1d-1d64b7632b3e" alt="Game Screen 2" height="600">
</p>

## Chess Algorithms and Techniques

### Principal Variation Search (PVS)

The Moriarty Chess Engine uses Principal Variation Search (PVS) as its chief algorithm. PVS is an optimized version of the Minimax algorithm with Alpha-Beta Pruning that assumes the first move is the best and performs a zero-window search for other moves.

### Minimax Algorithm with Alpha-Beta Pruning

- **Minimax**: Evaluates all possible moves up to a certain depth and chooses the move with the optimal outcome for the current player.
- **Alpha-Beta Pruning**: Optimizes the Minimax algorithm by cutting off branches that cannot influence the final decision, improving performance.

### Null Move Pruning

Null move pruning is used to skip certain moves and reduce the number of nodes evaluated when it’s clear that making a move is futile, thus speeding up the search process.

### Move Ordering

The engine uses the Most Valuable Victim - Least Valuable Attacker (MVV-LVA) heuristic and additional heuristics for development and center control to prioritize moves, enhancing the efficiency of alpha-beta pruning.

### Iterative Deepening

Iterative deepening search is implemented to progressively deepen the search tree one level at a time, keeping track of the best move found at each depth, thus ensuring optimal move selection within the time constraints.

### Positional Scoring

The engine uses predefined positional tables for different pieces, providing a positional score based on the location of each piece on the board. This helps the engine make more strategic decisions.

### Time Management

A stopwatch and time limits are employed to manage the search time effectively. If the time limit is exceeded, the best move found up to that point is returned.

### Special Rules Handling

The engine correctly handles castling, pawn promotion, and other special rules, ensuring a comprehensive and accurate chess experience.

## Installation

1. **Clone the repository:**

   ```sh
   git clone https://github.com/xajxatel/moriarty_chess_engine.git
   cd moriarty_chess_engine
