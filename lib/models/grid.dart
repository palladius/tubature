import 'package:equatable/equatable.dart';
import 'position.dart';
import 'tile.dart';

class Grid extends Equatable {
  final int rows;
  final int cols;
  final List<List<Tile>> tiles;

  const Grid(this.rows, this.cols, this.tiles);

  bool isValidPosition(Position pos) {
    return pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols;
  }

  Tile? tileAt(Position pos) {
    if (!isValidPosition(pos)) return null;
    return tiles[pos.row][pos.col];
  }

  Grid withRotatedTile(Position pos) {
    if (!isValidPosition(pos)) return this;
    final newTiles = List<List<Tile>>.generate(
      rows,
      (r) => List<Tile>.generate(
        cols,
        (c) {
          if (r == pos.row && c == pos.col) {
            return tiles[r][c].rotate();
          }
          return tiles[r][c];
        },
      ),
    );
    return Grid(rows, cols, newTiles);
  }

  @override
  List<Object?> get props => [rows, cols, tiles];
}
