# Moriarty Chess Engine

Moriarty is a powerful and cunning chess engine, inspired by the greatest arch-nemesis of Sherlock Holmes. This Flutter-based application features an interactive chessboard, animated text, and unique UI elements to provide an engaging chess-playing experience.

<p align="center">
  <img src="https://github.com/xajxatel/moriarty_chess_engine/assets/137952206/ac1ba677-783c-4dc0-a369-775a5b5e8816" alt="mor2" height="600">
</p>

## Features

- **Intelligent AI**: Play against Moriarty, who calculates every move with precision.
- **Interactive Chessboard**: Tap and move pieces with a responsive and intuitive interface.
- **Haptic Feedback**: Feel each move with subtle vibrations.

<p align="center">
  <img src="https://github.com/xajxatel/moriarty_chess_engine/assets/137952206/de9d88d1-f93a-4232-a019-69fb5781e044" alt="Game Screen 1" height="600">
  <img src="https://github.com/xajxatel/moriarty_chess_engine/assets/137952206/cd381f18-172e-474c-8e1d-1d64b7632b3e" alt="Game Screen 2" height="600">
</p>

### Minimax Algorithm with Alpha-Beta Pruning

The Moriarty Chess Engine uses the Minimax algorithm with Alpha-Beta Pruning to evaluate the best possible moves. This algorithm helps in efficiently searching the game tree by eliminating branches that don't need to be explored.

- **Minimax**: Evaluates all possible moves up to a certain depth and chooses the move with the optimal outcome for the current player.
- **Alpha-Beta Pruning**: Optimizes the Minimax algorithm by cutting off branches that cannot influence the final decision, improving performance.

### Positional Scoring

The engine uses predefined positional tables for different pieces, providing a positional score based on the location of each piece on the board. This helps the engine make more strategic decisions.

### Installation

1. **Clone the repository:**

   ```sh
   git clone https://github.com/yourusername/moriarty_chess_engine.git
   cd moriarty_chess_engine
