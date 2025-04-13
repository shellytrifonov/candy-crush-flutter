import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final int level;

  GameScreen({required this.level});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int score = 0;
  late int movesLeft;
  late int gridSize;
  late int targetScore;
  late int candyVariety;

  final List<String> candyImages = [
    'assets/candy_red.webp',
    'assets/candy_green.webp',
    'assets/candy_blue.webp',
    'assets/candy_yellow.webp',
    'assets/candy_orange.webp',
    'assets/candy_purple.webp',
  ];

  late List<List<String>> candyGrid;
  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    super.initState();
    gridSize = getGridSize(widget.level);
    movesLeft = getMovesForLevel(widget.level);
    targetScore = getTargetScore(widget.level);
    candyVariety = getCandyVariety(widget.level);
    _generateCandyGrid();
  }

  int getTargetScore(int level) => 200 + (level * 100);
  int getMovesForLevel(int level) => (20 - level).clamp(8, 20);
  int getGridSize(int level) => level < 4 ? 6 : level < 7 ? 7 : 8;
  int getCandyVariety(int level) => (4 + (level ~/ 3)).clamp(4, 6);

  void _generateCandyGrid() {
    candyGrid = List.generate(gridSize, (row) {
      return List.generate(gridSize, (col) {
        return candyImages[(row * gridSize + col + widget.level) % candyVariety];
      });
    });
  }

  void _onCandyTap(int row, int col) {
    if (selectedRow == null) {
      setState(() {
        selectedRow = row;
        selectedCol = col;
      });
    } else {
      if (_areNeighbors(selectedRow!, selectedCol!, row, col)) {
        setState(() {
          String temp = candyGrid[row][col];
          candyGrid[row][col] = candyGrid[selectedRow!][selectedCol!];
          candyGrid[selectedRow!][selectedCol!] = temp;

          final matches = findMatches();
          if (matches.isNotEmpty) {
            int removed = removeMatches(matches);
            score += removed * 10;
            dropCandies();
          } else {
            candyGrid[selectedRow!][selectedCol!] = candyGrid[row][col];
            candyGrid[row][col] = temp;
          }

          movesLeft--;
          if (movesLeft == 0) _checkGameOver();

          selectedRow = null;
          selectedCol = null;
        });
      } else {
        setState(() {
          selectedRow = null;
          selectedCol = null;
        });
      }
    }
  }

  bool _areNeighbors(int row1, int col1, int row2, int col2) {
    int dRow = (row1 - row2).abs();
    int dCol = (col1 - col2).abs();
    return (dRow == 1 && dCol == 0) || (dRow == 0 && dCol == 1);
  }

  List<List<bool>> findMatches() {
    List<List<bool>> matches =
        List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize - 2; col++) {
        String c1 = candyGrid[row][col];
        String c2 = candyGrid[row][col + 1];
        String c3 = candyGrid[row][col + 2];
        if (c1 == c2 && c2 == c3) {
          matches[row][col] = matches[row][col + 1] = matches[row][col + 2] = true;
        }
      }
    }

    for (int col = 0; col < gridSize; col++) {
      for (int row = 0; row < gridSize - 2; row++) {
        String c1 = candyGrid[row][col];
        String c2 = candyGrid[row + 1][col];
        String c3 = candyGrid[row + 2][col];
        if (c1 == c2 && c2 == c3) {
          matches[row][col] = matches[row + 1][col] = matches[row + 2][col] = true;
        }
      }
    }

    return matches;
  }

  int removeMatches(List<List<bool>> matches) {
    int removed = 0;
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (matches[row][col]) {
          candyGrid[row][col] = 'transparent';
          removed++;
        }
      }
    }
    return removed;
  }

  void dropCandies() {
    for (int col = 0; col < gridSize; col++) {
      int emptyRow = gridSize - 1;
      for (int row = gridSize - 1; row >= 0; row--) {
        if (candyGrid[row][col] != 'transparent') {
          candyGrid[emptyRow][col] = candyGrid[row][col];
          if (emptyRow != row) {
            candyGrid[row][col] = 'transparent';
          }
          emptyRow--;
        }
      }
      for (int row = emptyRow; row >= 0; row--) {
        candyGrid[row][col] =
            candyImages[(row + col + DateTime.now().millisecond) % candyVariety];
      }
    }
  }

  void _checkGameOver() {
    if (score >= targetScore) {
      if (widget.level < 10) {
        _goToNextLevel();
      } else {
        _showEndDialog('You Won!', 'You Have Completed All The Levels!');
      }
    } else {
      _showEndDialog('You Lost!', 'You Have Not Reached $targetScore Points');
    }
  }

  void _goToNextLevel() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('Level ${widget.level} Completed'),
        content: Text('Moving On To The Next Level...'),
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => GameScreen(level: widget.level + 1)),
      );
    });
  }

  void _showEndDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('Back'),
            onPressed: () {
              Navigator.of(context)..pop()..pop();
            },
          )
        ],
      ),
    );
  }

  Widget buildTopPanels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Moves left panel
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('Level: ${widget.level}'),
                Row(
                  children: [
                    Icon(Icons.swap_horiz),
                    Text('$movesLeft'),
                  ],
                )
              ],
            ),
          ),

          // Objectives panel
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(5, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    children: [
                      Image.asset(
                        candyImages[i],
                        width: 24,
                        height: 24,
                      ),
                      Text('4'),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCandyBoard() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          itemCount: gridSize * gridSize,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            int row = index ~/ gridSize;
            int col = index % gridSize;
            bool isSelected = selectedRow == row && selectedCol == col;
            final candy = candyGrid[row][col];

            return GestureDetector(
              onTap: () => _onCandyTap(row, col),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: Colors.pinkAccent, width: 3)
                      : null,
                ),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: candy == 'transparent'
                      ? Container(
                          key: ValueKey('empty_${row}_$col'),
                        )
                      : Image.asset(
                          candy,
                          key: ValueKey('$candy-${row}_$col'),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/game_background.webp',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                buildTopPanels(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Level: ${widget.level}',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                buildCandyBoard(),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => Navigator.of(context).pop(),
              backgroundColor: Colors.blue,
              child: Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}