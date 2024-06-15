import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moriarty_chess_engine/src/moriarty_core.dart';
import 'package:moriarty_chess_engine/src/moriarty_engine.dart';
import 'package:moriarty_chess_engine/src/moves.dart';

class ChessPage extends StatefulWidget {
  const ChessPage({super.key});

  @override
  State<ChessPage> createState() => _ChessPageState();
}

class _ChessPageState extends State<ChessPage> {
  Color secondaryColor = const Color(0xfff5811d);
  Color bgColor = const Color(0xff1E1E1E); // Dark Grey
  Color iconsTextColor = const Color(0xffFFFFFF);
  Color lightSquare = const Color(0xFFE0E0E0); // Light Gray
  Color darkSquare = const Color(0xFF4A4A4A); // Charcoal

  List<CellPosition> validMoves = [];
  late bool isPlayerTurn;
  bool isPlayerWhite = true;
  CellPosition? currSelectedElementPosition;
  late ChessEngine chessEngine;
  List<List<int>> boardData = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0]
  ];

  List<int> capturedByPlayer = [];
  List<int> capturedByCPU = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLandingPopup(context);
    });
  }

  void _showGameOverPopup(BuildContext context, String result) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  result,
                  style: GoogleFonts.robotoMono(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showDifficultyPopup(context);
                  },
                  child: Text(
                    'Play Again',
                    style: GoogleFonts.robotoMono(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCheckPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            'Check!!!',
            style: GoogleFonts.robotoMono(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Your king\'s in a bit of a bind now, isn\'t it?',
            style: GoogleFonts.robotoMono(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                backgroundColor:
                    Colors.grey.shade800, // Button background color
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                'OK',
                style: GoogleFonts.robotoMono(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTeamPickPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            'Choose your side!',
            style: GoogleFonts.robotoMono(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'What would you like to play as?',
            style: GoogleFonts.robotoMono(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _showDifficultyPopup(context, true);
              },
              style: TextButton.styleFrom(
                backgroundColor:
                    Colors.grey.shade800, // Button background color
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                'White',
                style: GoogleFonts.robotoMono(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _showDifficultyPopup(context, false);
              },
              style: TextButton.styleFrom(
                backgroundColor:
                    Colors.grey.shade800, // Button background color
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                'Black',
                style: GoogleFonts.robotoMono(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLandingPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          content: Text(
            'Every problem is an opportunity in disguise.',
            style: GoogleFonts.robotoMono(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _showTeamPickPopup(context);
              },
              style: TextButton.styleFrom(
                backgroundColor:
                    Colors.grey.shade800, // Button background color
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
              ),
              child: Text(
                'Lets play!!',
                style: GoogleFonts.robotoMono(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDifficultyPopup(BuildContext context, [bool? isWhite]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            'Select Difficulty',
            style: GoogleFonts.robotoMono(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(
                  'Too Easy',
                  style: GoogleFonts.robotoMono(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  initializeChessEngine(isWhite ?? true, Difficulty.tooEasy);
                },
              ),
              ListTile(
                title: Text(
                  'Easy',
                  style: GoogleFonts.robotoMono(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  initializeChessEngine(isWhite ?? true, Difficulty.easy);
                },
              ),
              ListTile(
                title: Text(
                  'Medium',
                  style: GoogleFonts.robotoMono(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  initializeChessEngine(isWhite ?? true, Difficulty.medium);
                },
              ),
              ListTile(
                title: Text(
                  'Hard',
                  style: GoogleFonts.robotoMono(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  initializeChessEngine(isWhite ?? true, Difficulty.hard);
                },
              ),
              ListTile(
                title: Text(
                  'Grandmaster',
                  style: GoogleFonts.robotoMono(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  initializeChessEngine(
                      isWhite ?? true, Difficulty.grandmaster);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void initializeChessEngine(bool isWhite, Difficulty difficulty) {
    isPlayerWhite = isWhite;
    String fenInput = '';
    List<String> parts = [];

    if (fenInput.isEmpty) {
      isPlayerTurn = isPlayerWhite;
    } else {
      if ((parts[1] == 'w' && isPlayerWhite) ||
          parts[1] == 'b' && !isPlayerWhite) {
        isPlayerTurn = true;
      } else {
        isPlayerTurn = false;
      }
    }

    if (!isPlayerWhite && fenInput.isNotEmpty) {
      var reversedFenPos = parts[0].split('').reversed.join('');
      parts[0] = reversedFenPos;
      fenInput = parts.join(' ');
    }
    ChessConfig config = ChessConfig(
        isPlayerAWhite: isPlayerWhite,
        difficulty: difficulty);
    chessEngine = ChessEngine(
      config,
      boardChangeCallback: (newData) {
        boardData = newData;
        setState(() {});
      },
      gameOverCallback: (gameStatus) {
        if (gameStatus == GameOver.blackWins) {
          _showGameOverPopup(context, 'Black wins');
        } else if (gameStatus == GameOver.whiteWins) {
          _showGameOverPopup(context, 'White wins');
        } else {
          _showGameOverPopup(context, 'Match Draw!');
        }
      },
      pawnPromotion: (isWhitePawn, targetPosition) {
        ChessPiece piece;
        if (isWhitePawn) {
          piece = ChessPiece.queen;
        } else {
          piece = ChessPiece.queen;
        }
        chessEngine.setPawnPromotion(targetPosition, piece);
      },
      checkCallback: (isInCheck) {
        if (isInCheck && isPlayerTurn) {
          HapticFeedback.vibrate(); // Add vibration here
          _showCheckPopup(context);
        }
      },
    );
    if (!isPlayerTurn) {
      Future.delayed(const Duration(seconds: 1), () {
        computerTurn();
      });
    }
  }

  void reloadBoard() {
    boardData = chessEngine.getBoardData();
    setState(() {});
  }

  void resetBoard() {
    _showTeamPickPopup(context);
  }

  Future<void> computerTurn() async {
    Future.delayed(const Duration(milliseconds: 200), () async {
      isPlayerTurn = false;
      MovesModel? pos = await chessEngine.generateBestMove(Duration(milliseconds: 4000));
      if (pos == null) {
        return;
      }
      isPlayerTurn = true;
      chessEngine.movePiece(pos);
      HapticFeedback.vibrate(); // Add vibration here
      resetMovesData();
      reloadBoard();
    });
  }

  void resetMovesData() {
    validMoves = [];
    currSelectedElementPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double boardSize = screenWidth * 0.97;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0, // No shadow
        backgroundColor: bgColor,

        title: Column(
          children: [
            SizedBox(
              height: 13,
            ),
            Text(
              "Moriarty",
              style:
                  GoogleFonts.robotoMono(color: iconsTextColor, fontSize: 24),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: screenWidth / 18,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 50, // Fixed height to prevent layout shift

              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'Every move is calculated. Every piece has its purpose...',
                    textStyle: GoogleFonts.robotoMono(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    speed: const Duration(milliseconds: 200),
                  ),
                ],
                isRepeatingAnimation: true,
                repeatForever: true,
              ),
            ),
          ),
          SizedBox(
            height: screenWidth / 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: capturedByCPU
                .map((piece) => Container(
                      width: 40,
                      height: 40,
                      child: Image.asset(getPeicePngImgPath(piece)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          Container(
            width: boardSize,
            height: boardSize,
            child: _chessBoard(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: capturedByPlayer
                .map((piece) => Container(
                      width: 40,
                      height: 40,
                      child: Image.asset(getPeicePngImgPath(piece)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: resetBoard,
            child: Text(
              'Reset Board',
              style: GoogleFonts.robotoMono(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0), // Rectangular shape
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: GoogleFonts.robotoMono(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chessBoard() {
    return GridView.builder(
      itemCount: 64,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemBuilder: (BuildContext context, int index) {
        Color color =
            ((index ~/ 8) + (index % 8)) % 2 == 0 ? lightSquare : darkSquare;
        for (var element in validMoves) {
          if (element.row == (index ~/ 8) && element.col == (index % 8)) {
            color = Color.fromARGB(236, 255, 217, 0);
            break;
          }
        }

        return chessBlock(boardData, index, color);
      },
    );
  }

  Widget chessBlock(List<List<int>> boardData, int index, Color color) {
    int row = index ~/ 8;
    int col = index % 8;

    String pieceImgPath = getPeicePngImgPath(boardData[row][col]);
    bool checkIfThisBlockIsValidMove() {
      for (var ele in validMoves) {
        if (ele.row == row && ele.col == col) {
          return true;
        }
      }
      return false;
    }

    bool checkIfClickAllowed() {
      if (!isPlayerTurn) {
        return false;
      }
      for (var ele in validMoves) {
        if (ele.row == row && ele.col == col) {
          return true;
        }
      }

      if ((isPlayerWhite && boardData[row][col] > 0) ||
          (!isPlayerWhite && boardData[row][col] < 0)) {
        return true;
      }
      return false;
    }

    blockClicked() async {
      if (!checkIfClickAllowed()) {
        resetMovesData();
        reloadBoard();
        return;
      }

      if (checkIfThisBlockIsValidMove() &&
          currSelectedElementPosition != null) {
        MovesModel move = MovesModel(
            targetPosition: CellPosition(row: row, col: col),
            currentPosition: CellPosition(
                row: currSelectedElementPosition!.row,
                col: currSelectedElementPosition!.col));
        chessEngine.movePiece(move);
        HapticFeedback.vibrate(); // Add vibration here
        resetMovesData();
        reloadBoard();
        await computerTurn();
        return;
      }

      resetMovesData();
      currSelectedElementPosition = CellPosition(row: row, col: col);
      validMoves = chessEngine.getValidMovesOfPeiceByPosition(
          chessEngine.getBoardData(), CellPosition(row: row, col: col));
      if (validMoves.isEmpty) {
        resetMovesData();
      }
      HapticFeedback.vibrate(); // Add vibration here
      reloadBoard();
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          await blockClicked();
        },
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
          child: Container(
            decoration: BoxDecoration(
              color: color,
            ),
            width: 40.0,
            height: 40.0,
            child: Container(
              child: pieceImgPath.isNotEmpty
                  ? Image.asset(pieceImgPath)
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  String getPeicePngImgPath(int piecePower) {
    if (piecePower == emptyCellPower) {
      return '';
    }
    String peicePath = 'assets/ChessPiece/';
    if (piecePower > 0) {
      peicePath += 'white_';
    } else {
      peicePath += 'black_';
    }
    String? fileName = filePath[piecePower.abs()];
    if (fileName == null) {
      return '';
    }
    return '$peicePath$fileName.png';
  }

  Map<int, String> filePath = {
    pawnPower: 'pawn',
    rookPower: 'rook',
    bishopPower: 'bishop',
    horsePower: 'horse',
    queenPower: 'queen',
    kingPower: 'king',
  };
}
