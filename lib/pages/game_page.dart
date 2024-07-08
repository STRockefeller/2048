import 'dart:math';

import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

enum Direction { up, down, left, right }

class _GamePageState extends State<GamePage> {
  List<List<int>> grid = List.generate(4, (_) => List.generate(4, (_) => 0));

  @override
  void initState() {
    super.initState();
    _addNewNumber();
    _addNewNumber();
  }

  List<Point<int>> _getEmptyCells() {
    List<Point<int>> emptyCells = [];

    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (grid[row][col] == 0) {
          emptyCells.add(Point(row, col));
        }
      }
    }

    return emptyCells;
  }

  void _addNewNumber() {
    var emptyCells = _getEmptyCells();
    Random random = Random();
    if (emptyCells.isNotEmpty) {
      Point<int> randomCell = emptyCells[random.nextInt(emptyCells.length)];
      grid[randomCell.x][randomCell.y] = random.nextInt(10) < 9 ? 2 : 4;
    }
  }

  List<int> _slideAndMerge(List<int> row) {
    // Step 1: remove zeroes
    List<int> newRow = row.where((num) => num != 0).toList();

    // Step 2: merge the same nums
    for (int i = 0; i < newRow.length - 1; i++) {
      if (newRow[i] == newRow[i + 1]) {
        newRow[i] *= 2;
        newRow[i + 1] = 0;
      }
    }

    // Step 3: remove zeroes
    newRow = newRow.where((num) => num != 0).toList();

    // Step 4: fill with zeroes
    while (newRow.length < 4) {
      newRow.add(0);
    }

    return newRow;
  }

  void _move(Direction direction) {
    setState(() {
      bool moved = false;
      switch (direction) {
        case Direction.left:
          for (int row = 0; row < 4; row++) {
            List<int> currentRow = grid[row];
            List<int> newRow = _slideAndMerge(currentRow);
            if (currentRow != newRow) {
              grid[row] = newRow;
              moved = true;
            }
          }
          break;
        case Direction.right:
          for (int row = 0; row < 4; row++) {
            List<int> currentRow = grid[row].reversed.toList();
            List<int> newRow = _slideAndMerge(currentRow).reversed.toList();
            if (currentRow != newRow) {
              grid[row] = newRow;
              moved = true;
            }
          }
          break;
        case Direction.up:
          for (int col = 0; col < 4; col++) {
            List<int> currentCol = [
              grid[0][col],
              grid[1][col],
              grid[2][col],
              grid[3][col]
            ];
            List<int> newCol = _slideAndMerge(currentCol);
            for (int row = 0; row < 4; row++) {
              if (grid[row][col] != newCol[row]) {
                grid[row][col] = newCol[row];
                moved = true;
              }
            }
          }
          break;
        case Direction.down:
          for (int col = 0; col < 4; col++) {
            List<int> currentCol = [
              grid[0][col],
              grid[1][col],
              grid[2][col],
              grid[3][col]
            ].reversed.toList();
            List<int> newCol = _slideAndMerge(currentCol).reversed.toList();
            for (int row = 0; row < 4; row++) {
              if (grid[row][col] != newCol[row]) {
                grid[row][col] = newCol[row];
                moved = true;
              }
            }
          }
          break;
      }
      if (moved) {
        _addNewNumber();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2048'),
      ),
      body: GestureDetector(
        onPanEnd: (details) {
          const threshold = 20;
          final dx = details.velocity.pixelsPerSecond.dx;
          final dy = details.velocity.pixelsPerSecond.dy;

          if (dx.abs() > dy.abs()) {
            if (dx > threshold) {
              _move(Direction.right);
            } else if (dx < -threshold) {
              _move(Direction.left);
            }
          } else {
            if (dy > threshold) {
              _move(Direction.down);
            } else if (dy < -threshold) {
              _move(Direction.up);
            }
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (col) {
                return Container(
                  margin: EdgeInsets.all(4.0),
                  width: 70.0,
                  height: 70.0,
                  decoration: BoxDecoration(
                    color:
                        grid[row][col] == 0 ? Colors.grey[300] : Colors.orange,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      grid[row][col] == 0 ? '' : '${grid[row][col]}',
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
