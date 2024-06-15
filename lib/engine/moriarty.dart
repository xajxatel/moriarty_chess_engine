// ignore_for_file: file_names

import 'dart:async';
import 'dart:math';

import 'package:moriarty_chess_engine/helpers/models.dart';
import 'package:moriarty_chess_engine/helpers/moves.dart';

class MoriartyChessEngine {
  // Position tables
  List<List<double>> _whitePawnTable = [];
  List<List<double>> _whiteHorseTable = [];
  List<List<double>> _whiteBishopTable = [];
  List<List<double>> _whiteRookTable = [];
  List<List<double>> _whiteQueenTable = [];
  List<List<double>> _whiteKingMidGameTable = [];
  List<List<double>> _whiteKingEndgameTable = [];

  List<List<double>> _blackPawnTable = [];
  List<List<double>> _blackHorseTable = [];
  List<List<double>> _blackBishopTable = [];
  List<List<double>> _blackRookTable = [];
  List<List<double>> _blackQueenTable = [];
  List<List<double>> _blackKingMidGameTable = [];
  List<List<double>> _blackKingEndgameTable = [];

  List<List<int>> _board = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
  ];
  final List<MovesLogModel> _moveLogs = [];
  int _maxDepth = 1;
  late bool boardViewIsWhite;
  late ChessConfig chessConfig;
  late Function(List<List<int>>) _boardChangeCallback;
  Function(bool, CellPosition)? _pawnPromotion;
  late Function(GameOver) _gameOverCallback;
  late Function(bool) _checkCallback;

  int _halfMoveClock = 0;
  int _fullMoveNumber = 0;

  MoriartyChessEngine(ChessConfig config,
      {required Function(List<List<int>>) boardChangeCallback,
      required Function(GameOver) gameOverCallback,
      required Function(bool) checkCallback,
      Function(bool, CellPosition)? pawnPromotion}) {
    chessConfig = config;
    boardViewIsWhite = chessConfig.isPlayerAWhite;
    _initializeBoard();
    _initializePositionPointsTable();
    _initializeDifficultyMode();
    _boardChangeCallback = boardChangeCallback;
    _gameOverCallback = gameOverCallback;
    _checkCallback = checkCallback;
    _pawnPromotion = pawnPromotion;
    _notifyBoardChangeCallback();
  }

  _initializeDifficultyMode() {
    if (chessConfig.difficulty == Difficulty.tooEasy) {
      _maxDepth = 2;
    } else if (chessConfig.difficulty == Difficulty.easy) {
      _maxDepth = 3;
    } else if (chessConfig.difficulty == Difficulty.medium) {
      _maxDepth = 4;
    } else if (chessConfig.difficulty == Difficulty.hard) {
      _maxDepth = 5;
    } else if (chessConfig.difficulty == Difficulty.grandmaster) {
      _maxDepth = 8;
    }
  }

  _initializePositionPointsTable() {
    if (chessConfig.isPlayerAWhite) {
      _setBottomToTopPositionPoints();
    } else {
      _setTopToBottomPositionPoints();
    }
  }

  _setBottomToTopPositionPoints() {
    _whitePawnTable = pawnSquareTable;
    _whiteHorseTable = horseSquareTable;
    _whiteBishopTable = bishopSquareTable;
    _whiteRookTable = rookSquareTable;
    _whiteQueenTable = queenSquareTable;
    _whiteKingMidGameTable = kingMidGameSquareTable;
    _whiteKingEndgameTable = kingEndGameSquareTable;

    _blackPawnTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(pawnSquareTable);
    _blackHorseTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(horseSquareTable);
    _blackBishopTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(bishopSquareTable);
    _blackRookTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(rookSquareTable);
    _blackQueenTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(queenSquareTable);
    _blackKingMidGameTable = ChessEngineHelpers.deepCopyAndReversePositionTable(
        kingMidGameSquareTable);
    _blackKingEndgameTable = ChessEngineHelpers.deepCopyAndReversePositionTable(
        kingEndGameSquareTable);
  }

  _setTopToBottomPositionPoints() {
    _blackPawnTable = pawnSquareTable;
    _blackHorseTable = horseSquareTable;
    _blackBishopTable = bishopSquareTable;
    _blackRookTable = rookSquareTable;
    _blackQueenTable = queenSquareTable;
    _blackKingMidGameTable = kingMidGameSquareTable;
    _blackKingEndgameTable = kingEndGameSquareTable;

    _whitePawnTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(pawnSquareTable);
    _whiteHorseTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(horseSquareTable);
    _whiteBishopTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(bishopSquareTable);
    _whiteRookTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(rookSquareTable);
    _whiteQueenTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(queenSquareTable);
    _whiteKingMidGameTable = ChessEngineHelpers.deepCopyAndReversePositionTable(
        kingMidGameSquareTable);
    _whiteKingEndgameTable = ChessEngineHelpers.deepCopyAndReversePositionTable(
        kingEndGameSquareTable);
  }

  int getHalfMoveClock() {
    return _halfMoveClock;
  }

  int getFullMoveNumber() {
    return _fullMoveNumber;
  }

  void _notifyBoardChangeCallback() {
    _boardChangeCallback(_board);
  }

  void _notifyGameOverStatus(GameOver status) {
    _gameOverCallback(status);
  }

  List<List<int>> getBoardData() {
    return _board;
  }

  List<MovesLogModel> getMovesLogsData() {
    return _moveLogs;
  }

  MovesModel? generateRandomMove() {
    List<CellPosition> allowedPeiceCoordinates = _getAllowedPieceCoordinates();
    allowedPeiceCoordinates.shuffle();
    for (var ele in allowedPeiceCoordinates) {
      List<CellPosition> validMove =
          getValidMovesOfPeiceByPosition(_board, ele);
      if (validMove.isEmpty) {
        continue;
      }
      validMove.shuffle();
      return MovesModel(
          currentPosition: CellPosition(row: ele.row, col: ele.col),
          targetPosition:
              CellPosition(row: validMove[0].row, col: validMove[0].col));
    }
    return null;
  }

  List<CellPosition> _getAllowedPieceCoordinates() {
    List<CellPosition> allowedPiecesPosition = [];

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (chessConfig.isPlayerAWhite && _board[i][j] < 0) {
          allowedPiecesPosition.add(CellPosition(row: i, col: j));
        } else if (!chessConfig.isPlayerAWhite && _board[i][j] > 0) {
          allowedPiecesPosition.add(CellPosition(row: i, col: j));
        }
      }
    }

    return allowedPiecesPosition;
  }

  List<MovesModel> _getWhitePossibleMove(List<List<int>> boardCopy) {
    List<MovesModel> movesList = [];
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (boardCopy[i][j] > emptyCellPower) {
          CellPosition currentPosition = CellPosition(row: i, col: j);
          List<CellPosition> possibleMove =
              getValidMovesOfPeiceByPosition(boardCopy, currentPosition);
          for (CellPosition targetPosition in possibleMove) {
            movesList.add(MovesModel(
                currentPosition: currentPosition,
                targetPosition: targetPosition));
          }
        }
      }
    }
    return movesList;
  }

  List<MovesModel> _getBlackPossibleMove(List<List<int>> boardCopy) {
    List<MovesModel> movesList = [];
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (boardCopy[i][j] < emptyCellPower) {
          CellPosition currentPosition = CellPosition(row: i, col: j);
          List<CellPosition> possibleMove =
              getValidMovesOfPeiceByPosition(boardCopy, currentPosition);
          for (CellPosition targetPosition in possibleMove) {
            movesList.add(MovesModel(
                currentPosition: currentPosition,
                targetPosition: targetPosition));
          }
        }
      }
    }
    return movesList;
  }

  List<CellPosition> getValidMovesOfPeiceByPosition(
      List<List<int>> currBoard, CellPosition currentPosition) {
    var peice = currBoard[currentPosition.row][currentPosition.col];
    List<CellPosition> movesWithPossibleCheck = [];
    if (peice.abs() == horsePower) {
      movesWithPossibleCheck = Moves.getValidHorseMoves(
          currBoard, currentPosition, boardViewIsWhite);
    }
    if (peice.abs() == rookPower) {
      movesWithPossibleCheck = Moves.getValidRookMoves(
          currBoard, currentPosition, boardViewIsWhite);
    } else if (peice.abs() == bishopPower) {
      movesWithPossibleCheck = Moves.getValidBishopMoves(
          currBoard, currentPosition, boardViewIsWhite);
    } else if (peice.abs() == queenPower) {
      movesWithPossibleCheck = Moves.getValidQueenMoves(
          currBoard, currentPosition, boardViewIsWhite);
    } else if (peice.abs() == kingPower) {
      movesWithPossibleCheck = Moves.getValidKingMove(
          currBoard, currentPosition, boardViewIsWhite, _moveLogs);
    } else if (peice.abs() == pawnPower) {
      movesWithPossibleCheck = Moves.getValidPawnMove(
          currBoard, currentPosition, boardViewIsWhite);
    }

    return movesWithPossibleCheck;
  }

  bool _isGameOverForThisBoard(List<List<int>> currBoard) {
    int kingCount = 0;
    for (List<int> row in currBoard) {
      for (int piece in row) {
        if (piece.abs() == kingPower) {
          kingCount += 1;
          if (kingCount == 2) {
            return false;
          }
        }
      }
    }
    return true;
  }

  int _nodeCounter = 0;
 



MoveScore _principalVariationSearch(List<List<int>> currBoard, int depth, double alpha, double beta, bool maximizingPlayer, {bool isPvNode = true, bool allowNullMove = true, required Stopwatch stopwatch, required Duration timeLimit}) {
  _nodeCounter++; // Increment the counter each time the function is called

  // Check if the time limit has been exceeded
  if (stopwatch.elapsed > timeLimit) {
    // Return a fail-soft value indicating the search was cut off due to time limit
    return MoveScore(move: null, score: maximizingPlayer ? -double.infinity : double.infinity);
  }

  if (depth == 0 || _isGameOverForThisBoard(currBoard)) {
    return MoveScore(move: null, score: _getScoreForBoard(currBoard));
  }

  // Null move pruning
  if (allowNullMove && depth > 2 && !isPvNode && !maximizingPlayer && !_isInCheck(currBoard)) {
    List<List<int>> boardCopy = ChessEngineHelpers.deepCopyBoard(currBoard);
    // Make a null move (skip a turn for the opponent)
    double nullMoveEval = -_principalVariationSearch(boardCopy, depth - 1 - 2, -beta, -beta + 1, !maximizingPlayer, isPvNode: false, allowNullMove: false, stopwatch: stopwatch, timeLimit: timeLimit).score;
    if (nullMoveEval >= beta) {
      return MoveScore(move: null, score: beta); // Prune the branch
    }
  }

  if (maximizingPlayer) {
    double maxEval = -double.infinity;
    MovesModel? bestMove;
    List<MovesModel> possibleMoves = _getWhitePossibleMove(currBoard);
    possibleMoves.sort((a, b) => _compareMoves(a, b, currBoard, true)); // Move ordering

    for (int i = 0; i < possibleMoves.length; i++) {
      MovesModel possibleMove = possibleMoves[i];
      List<List<int>> boardCopy = ChessEngineHelpers.deepCopyBoard(currBoard);
      _movePieceForMinMax(boardCopy, possibleMove);
      
      double evaluation;
      if (i == 0 || !isPvNode) {
        // Full search for the first move or if not a PV node
        evaluation = _principalVariationSearch(boardCopy, depth - 1, alpha, beta, false, stopwatch: stopwatch, timeLimit: timeLimit).score;
      } else {
        // Principal Variation Search for subsequent moves
        evaluation = _principalVariationSearch(boardCopy, depth - 1, alpha, alpha + 1, false, isPvNode: false, stopwatch: stopwatch, timeLimit: timeLimit).score;
        if (evaluation > alpha && evaluation < beta) {
          evaluation = _principalVariationSearch(boardCopy, depth - 1, alpha, beta, false, stopwatch: stopwatch, timeLimit: timeLimit).score;
        }
      }

      MovesModel undoingMove = MovesModel(currentPosition: possibleMove.targetPosition, targetPosition: possibleMove.currentPosition);
      _movePieceForMinMax(boardCopy, undoingMove);

      if (evaluation > maxEval) {
        maxEval = evaluation;
        bestMove = possibleMove;
      }
      alpha = max<double>(alpha, maxEval);
      if (beta <= alpha) {
        break;
      }
    }
    return MoveScore(move: bestMove, score: maxEval);
  } else {
    double minEval = double.infinity;
    MovesModel? bestMove;
    List<MovesModel> possibleMoves = _getBlackPossibleMove(currBoard);
    possibleMoves.sort((a, b) => _compareMoves(a, b, currBoard, false)); // Move ordering

    for (int i = 0; i < possibleMoves.length; i++) {
      MovesModel possibleMove = possibleMoves[i];
      List<List<int>> boardCopy = ChessEngineHelpers.deepCopyBoard(currBoard);
      _movePieceForMinMax(boardCopy, possibleMove);
      
      double evaluation;
      if (i == 0 || !isPvNode) {
        // Full search for the first move or if not a PV node
        evaluation = _principalVariationSearch(boardCopy, depth - 1, alpha, beta, true, stopwatch: stopwatch, timeLimit: timeLimit).score;
      } else {
        // Principal Variation Search for subsequent moves
        evaluation = _principalVariationSearch(boardCopy, depth - 1, beta - 1, beta, true, isPvNode: false, stopwatch: stopwatch, timeLimit: timeLimit).score;
        if (evaluation > alpha && evaluation < beta) {
          evaluation = _principalVariationSearch(boardCopy, depth - 1, alpha, beta, true, stopwatch: stopwatch, timeLimit: timeLimit).score;
        }
      }

      MovesModel undoingMove = MovesModel(currentPosition: possibleMove.targetPosition, targetPosition: possibleMove.currentPosition);
      _movePieceForMinMax(boardCopy, undoingMove);

      if (evaluation < minEval) {
        minEval = evaluation;
        bestMove = possibleMove;
      }
      beta = min<double>(beta, minEval);
      if (beta <= alpha) {
        break;
      }
    }
    return MoveScore(move: bestMove, score: minEval);
  }
}

MoveScore iterativeDeepeningSearch(List<List<int>> board, int maxDepth, bool maximizingPlayer, Duration timeLimit) {
  double alpha = -double.infinity;
  double beta = double.infinity;
  MoveScore bestMoveScore = MoveScore(move: null, score: maximizingPlayer ? -double.infinity : double.infinity);
  MovesModel? bestMove;

  Stopwatch stopwatch = Stopwatch()..start();

  for (int currentDepth = 1; currentDepth <= maxDepth; currentDepth++) {
    _nodeCounter = 0; // Reset the node counter at each depth
    
    bestMoveScore = _principalVariationSearch(board, currentDepth, alpha, beta, maximizingPlayer, stopwatch: stopwatch, timeLimit: timeLimit);
    
    // Calculate and print time taken for current depth
    
    // print('Depth: $currentDepth, Nodes searched: $_nodeCounter, Time taken: ${depthTimeTaken.inMilliseconds} ms');
    
    // Check if the time limit has been exceeded
    if (stopwatch.elapsed > timeLimit) {
      // print('Time Limit Exceeded (TLE) at depth $currentDepth');
      break; // Exit if the time limit is exceeded
    }

    // Update the best move if the time limit has not been exceeded
    if (bestMoveScore.move != null) {
      bestMove = bestMoveScore.move;
    }
  }

  stopwatch.stop();
  // Return the best move found within the time limit
  return MoveScore(move: bestMove, score: bestMoveScore.score);
}

Future<MovesModel?> generateBestMove(Duration timeLimit) async {
  await Future.delayed(const Duration(milliseconds: 10));
  MoveScore res = iterativeDeepeningSearch(_board, _maxDepth, !chessConfig.isPlayerAWhite, timeLimit);
  // print('Total nodes searched: $_nodeCounter'); // Print the counter value
  return res.move;
}





  int _compareMoves(MovesModel a, MovesModel b, List<List<int>> board,
      bool maximizingPlayer) {
    int aValue = board[a.targetPosition.row][a.targetPosition.col].abs();
    int bValue = board[b.targetPosition.row][b.targetPosition.col].abs();

    int aAttackerValue =
        board[a.currentPosition.row][a.currentPosition.col].abs();
    int bAttackerValue =
        board[b.currentPosition.row][b.currentPosition.col].abs();

    // MVV-LVA for captures
    if (aValue != 0 && bValue != 0) {
      int aMVVLVA = aValue - aAttackerValue;
      int bMVVLVA = bValue - bAttackerValue;
      return bMVVLVA - aMVVLVA; // Higher MVV-LVA first
    }

    // If one move is a capture and the other is not, prioritize the capture
    if (aValue != 0) return -1; // a is a capture, b is not
    if (bValue != 0) return 1; // b is a capture, a is not

    // Heuristics for development and center control
    int aDevelopmentScore = _evaluateMoveForDevelopment(a, board);
    int bDevelopmentScore = _evaluateMoveForDevelopment(b, board);
    if (aDevelopmentScore != bDevelopmentScore) {
      return bDevelopmentScore -
          aDevelopmentScore; // Higher development score first
    }

    int aCenterControlScore = _evaluateMoveForCenterControl(a);
    int bCenterControlScore = _evaluateMoveForCenterControl(b);
    return bCenterControlScore -
        aCenterControlScore; // Higher center control score first
  }

  int _evaluateMoveForDevelopment(MovesModel move, List<List<int>> board) {
    // Develop knights and bishops towards the center
    int piece = board[move.currentPosition.row][move.currentPosition.col];
    int targetRow = move.targetPosition.row;
    int targetCol = move.targetPosition.col;

    if (piece.abs() == horsePower || piece.abs() == bishopPower) {
      // Prioritize moves that bring knights and bishops to central squares
      if ((targetRow == 2 ||
              targetRow == 3 ||
              targetRow == 4 ||
              targetRow == 5) &&
          (targetCol == 2 ||
              targetCol == 3 ||
              targetCol == 4 ||
              targetCol == 5)) {
        return 1; // Higher score for central squares
      }
    }

    return 0; // Default score for other moves
  }

  int _evaluateMoveForCenterControl(MovesModel move) {
    // Control the center of the board (d4, e4, d5, e5)
    int row = move.targetPosition.row;
    int col = move.targetPosition.col;

    if ((row == 3 || row == 4) && (col == 3 || col == 4)) {
      return 1; // Higher score for central squares
    }

    return 0; // Default score for other moves
  }

  double _getScoreForBoard(List<List<int>> currBoard) {
    double overallScore = 0;

    overallScore += _getMaterialScore(currBoard);
    overallScore += _getPositionalScore(currBoard);

    return overallScore;
  }

  double _getMaterialScore(List<List<int>> currBoard) {
    double materialScore = 0;

    for (int row = 0; row < currBoard.length; row++) {
      for (int col = 0; col < currBoard.length; col++) {
        int piece = currBoard[row][col];
        switch (piece.abs()) {
          case pawnPower:
            materialScore += pawnPower * (piece > 0 ? 1 : -1);
            break;
          case rookPower:
            materialScore += rookPower * (piece > 0 ? 1 : -1);
            break;
          case horsePower:
            materialScore += horsePower * (piece > 0 ? 1 : -1);
            break;
          case bishopPower:
            materialScore += bishopPower * (piece > 0 ? 1 : -1);
            break;
          case queenPower:
            materialScore += queenPower * (piece > 0 ? 1 : -1);
            break;
          case kingPower:
            materialScore += kingPower * (piece > 0 ? 1 : -1);
            break;
          default:
            break;
        }
      }
    }

    return materialScore;
  }

  double _getPositionalScore(List<List<int>> currBoard) {
    double positionalScore = 0;
    for (int row = 0; row < currBoard.length; row++) {
      for (int col = 0; col < currBoard.length; col++) {
        int piece = currBoard[row][col];
        if (piece == emptyCellPower) {
          continue;
        }
        bool isWhitePiece = piece > emptyCellPower;
        double pieceScore = 0;
        if (isWhitePiece) {
          if (piece.abs() == pawnPower) {
            pieceScore = _whitePawnTable[row][col];
          } else if (piece.abs() == horsePower) {
            pieceScore = _whiteHorseTable[row][col];
          } else if (piece.abs() == bishopPower) {
            pieceScore = _whiteBishopTable[row][col];
          } else if (piece.abs() == rookPower) {
            pieceScore = _whiteRookTable[row][col];
          } else if (piece.abs() == kingPower) {
            if (_isEndGame(currBoard, true)) {
              pieceScore = _whiteKingEndgameTable[row][col];
            } else {
              pieceScore = _whiteKingMidGameTable[row][col];
            }
          } else if (piece.abs() == queenPower) {
            pieceScore = _whiteQueenTable[row][col];
          }
        } else {
          if (piece.abs() == pawnPower) {
            pieceScore = _blackPawnTable[row][col];
          } else if (piece.abs() == horsePower) {
            pieceScore = _blackHorseTable[row][col];
          } else if (piece.abs() == bishopPower) {
            pieceScore = _blackBishopTable[row][col];
          } else if (piece.abs() == rookPower) {
            pieceScore = _blackRookTable[row][col];
          } else if (piece.abs() == kingPower) {
            if (_isEndGame(currBoard, false)) {
              pieceScore = _blackKingEndgameTable[row][col];
            } else {
              pieceScore = _blackKingMidGameTable[row][col];
            }
          } else if (piece.abs() == queenPower) {
            pieceScore = _blackQueenTable[row][col];
          }
        }
        if (isWhitePiece) {
          positionalScore += pieceScore;
        } else {
          positionalScore -= pieceScore;
        }
      }
    }

    return positionalScore;
  }

  bool _isEndGame(List<List<int>> curBoard, bool endGameCheckForWhite) {
    bool whiteQueenAlive = false;
    bool blackQueenAlive = false;
    int whiteMinorPieceCount = 0;
    int blackMinorPieceCount = 0;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        switch (curBoard[i][j]) {
          case queenPower:
            {
              whiteQueenAlive = true;
              break;
            }
          case const (-queenPower):
            {
              blackQueenAlive = true;
              break;
            }
          case const (bishopPower):
          case const (horsePower):
            {
              whiteMinorPieceCount += 1;
              break;
            }
          case const (-bishopPower):
          case const (-horsePower):
            {
              blackMinorPieceCount += 1;
              break;
            }
        }
        if (endGameCheckForWhite) {
          if (whiteQueenAlive && whiteMinorPieceCount > 2) {
            return false;
          }
        } else {
          if (blackQueenAlive && blackMinorPieceCount > 2) {
            return false;
          }
        }
      }
    }
    if ((!whiteQueenAlive && !blackQueenAlive)) {
      return true;
    }
    return false;
  }

  void _movePieceForMinMax(List<List<int>> currBoard, MovesModel moves) {
    try {
      currBoard[moves.targetPosition.row][moves.targetPosition.col] =
          currBoard[moves.currentPosition.row][moves.currentPosition.col];
      currBoard[moves.currentPosition.row][moves.currentPosition.col] =
          emptyCellPower;
    } catch (ex) {
      // Do Nothing
    }
  }

  setPawnPromotion(CellPosition targetPos, ChessPiece piece) {
    _setPawnPromotion(_board, targetPos, piece);
  }

  _setPawnPromotion(
      List<List<int>> currBoard, CellPosition targetPos, ChessPiece piece) {
    if (piece != ChessPiece.king && piece != ChessPiece.pawn) {
      int isWhite = currBoard[targetPos.row][targetPos.col] > 0 ? 1 : -1;
      currBoard[targetPos.row][targetPos.col] =
          isWhite * chessPieceValue[piece]!;
      _notifyBoardChangeCallback();
    }
  }

  _updateHalfMoveClock(MovesModel move) {
    if ((_board[move.currentPosition.row][move.currentPosition.col].abs() ==
            pawnPower) ||
        (_board[move.currentPosition.row][move.currentPosition.col] > 0 &&
            _board[move.targetPosition.row][move.targetPosition.col] < 0) ||
        (_board[move.currentPosition.row][move.currentPosition.col] < 0 &&
            _board[move.targetPosition.row][move.targetPosition.col] > 0)) {
      _halfMoveClock = 0;
    } else {
      _halfMoveClock += 1;
    }
  }

  _updateFullMoveNumber(MovesModel move) {
    if (_board[move.currentPosition.row][move.currentPosition.col] < 0) {
      _fullMoveNumber += 1;
    }
  }

  void movePiece(MovesModel move) {
    _updateHalfMoveClock(move);
    _updateFullMoveNumber(move);
    if (_canPromotePawn(_board, move)) {
      if (_pawnPromotion != null) {
        bool isWhitePiece =
            _board[move.currentPosition.row][move.currentPosition.col] > 0;
        Future.delayed(const Duration(milliseconds: 100), () {
          _pawnPromotion!(isWhitePiece, move.targetPosition);
        });
      }
    }

    if (_board[move.currentPosition.row][move.currentPosition.col].abs() ==
            kingPower &&
        ((move.currentPosition.col - move.targetPosition.col).abs() == 2)) {
      _performCastling(_board, move);
    } else {
      _board[move.targetPosition.row][move.targetPosition.col] =
          _board[move.currentPosition.row][move.currentPosition.col];
      _board[move.currentPosition.row][move.currentPosition.col] =
          emptyCellPower;
    }
    _moveLogs.add(MovesLogModel(
        move: move,
        piece: _board[move.targetPosition.row][move.targetPosition.col]));
    _notifyCheckStatus();
    GameOver? gameOverStatus = _checkIfGameOver(
        _board[move.targetPosition.row][move.targetPosition.col] > 0);
    if (gameOverStatus != null) {
      _notifyGameOverStatus(gameOverStatus);
    }
    _notifyBoardChangeCallback();
  }

  void _notifyCheckStatus() {
    bool isInCheck = _isInCheck(_board);
    _checkCallback(isInCheck);
  }

  bool _isInCheck(List<List<int>> board) {
    CellPosition? whiteKingPosition;
    CellPosition? blackKingPosition;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        int piece = board[row][col];
        if (piece == kingPower) {
          whiteKingPosition = CellPosition(row: row, col: col);
        } else if (piece == -kingPower) {
          blackKingPosition = CellPosition(row: row, col: col);
        }
      }
    }

    if (whiteKingPosition != null) {
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          int piece = board[row][col];
          if (piece < 0) {
            List<CellPosition> validMoves = getValidMovesOfPeiceByPosition(
                board, CellPosition(row: row, col: col));
            for (CellPosition move in validMoves) {
              if (move.row == whiteKingPosition.row &&
                  move.col == whiteKingPosition.col) {
                return true;
              }
            }
          }
        }
      }
    }

    if (blackKingPosition != null) {
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          int piece = board[row][col];
          if (piece > 0) {
            List<CellPosition> validMoves = getValidMovesOfPeiceByPosition(
                board, CellPosition(row: row, col: col));
            for (CellPosition move in validMoves) {
              if (move.row == blackKingPosition.row &&
                  move.col == blackKingPosition.col) {
                return true;
              }
            }
          }
        }
      }
    }

    return false;
  }

  void _performCastling(List<List<int>> currBoard, MovesModel move) {
    currBoard[move.targetPosition.row][move.targetPosition.col] =
        currBoard[move.currentPosition.row][move.currentPosition.col];
    currBoard[move.currentPosition.row][move.currentPosition.col] =
        emptyCellPower;

    if (move.targetPosition.col > move.currentPosition.col) {
      currBoard[move.currentPosition.row][move.currentPosition.col + 1] =
          currBoard[move.currentPosition.row][7];
      currBoard[move.currentPosition.row][7] = emptyCellPower;
    } else {
      currBoard[move.currentPosition.row][move.currentPosition.col - 1] =
          currBoard[move.currentPosition.row][0];
      currBoard[move.currentPosition.row][0] = emptyCellPower;
    }
  }

  bool _canPromotePawn(List<List<int>> currBoard, MovesModel move) {
    if (currBoard[move.currentPosition.row][move.currentPosition.col] ==
            pawnPower &&
        (move.targetPosition.row == 0 || move.targetPosition.row == 7)) {
      return true;
    }
    return false;
  }

  GameOver? _checkIfGameOver(bool islastMoveByWhite) {
    if (_halfMoveClock > 99) {
      return GameOver.draw;
    }
    bool onlyKingsInBoard = true;
    for (var rowEle in _board) {
      for (var ele in rowEle) {
        if (ele.abs() != kingPower) {
          onlyKingsInBoard = false;
          break;
        }
      }
    }
    if (onlyKingsInBoard) {
      return GameOver.draw;
    }
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (_board[i][j] != emptyCellPower) {
          if ((islastMoveByWhite && _board[i][j] < 0) ||
              (!islastMoveByWhite && _board[i][j] > 0)) {
            List<CellPosition> possible = getValidMovesOfPeiceByPosition(
                _board, CellPosition(row: i, col: j));
            if (possible.isNotEmpty) {
              return null;
            }
          }
        }
      }
    }
    if (islastMoveByWhite) {
      return GameOver.whiteWins;
    } else {
      return GameOver.blackWins;
    }
  }

  _initializeBoard() {
    List<List<int>> chessBoard = [
      [
        -chessPieceValue[ChessPiece.rook]!,
        -chessPieceValue[ChessPiece.horse]!,
        -chessPieceValue[ChessPiece.bishop]!,
        -chessPieceValue[ChessPiece.queen]!,
        -chessPieceValue[ChessPiece.king]!,
        -chessPieceValue[ChessPiece.bishop]!,
        -chessPieceValue[ChessPiece.horse]!,
        -chessPieceValue[ChessPiece.rook]!,
      ],
      [
        -chessPieceValue[ChessPiece.pawn]!,
        -chessPieceValue[ChessPiece.pawn]!,
        -chessPieceValue[ChessPiece.pawn]!,
        -chessPieceValue[ChessPiece.pawn]!,
        -chessPieceValue[ChessPiece.pawn]!,
        -chessPieceValue[ChessPiece.pawn]!,
        -chessPieceValue[ChessPiece.pawn]!,
        -chessPieceValue[ChessPiece.pawn]!,
      ],
      [
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!
      ],
      [
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!
      ],
      [
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!
      ],
      [
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!
      ],
      [
        chessPieceValue[ChessPiece.pawn]!,
        chessPieceValue[ChessPiece.pawn]!,
        chessPieceValue[ChessPiece.pawn]!,
        chessPieceValue[ChessPiece.pawn]!,
        chessPieceValue[ChessPiece.pawn]!,
        chessPieceValue[ChessPiece.pawn]!,
        chessPieceValue[ChessPiece.pawn]!,
        chessPieceValue[ChessPiece.pawn]!,
      ],
      [
        chessPieceValue[ChessPiece.rook]!,
        chessPieceValue[ChessPiece.horse]!,
        chessPieceValue[ChessPiece.bishop]!,
        chessPieceValue[ChessPiece.queen]!,
        chessPieceValue[ChessPiece.king]!,
        chessPieceValue[ChessPiece.bishop]!,
        chessPieceValue[ChessPiece.horse]!,
        chessPieceValue[ChessPiece.rook]!,
      ]
    ];
    if (!chessConfig.isPlayerAWhite) {
      for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 8; j++) {
          chessBoard[i][j] = (-1 * chessBoard[i][j]);
        }
      }
      for (int i = 6; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
          chessBoard[i][j] = (-1 * chessBoard[i][j]);
        }
      }
    }
    _board = chessBoard;
  }
}
