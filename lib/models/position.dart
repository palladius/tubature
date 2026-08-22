import 'package:equatable/equatable.dart';
import 'direction.dart';

class Position extends Equatable {
  final int row;
  final int col;

  const Position(this.row, this.col);

  Position neighbor(Direction direction) {
    final delta = direction.delta;
    return Position(row + delta.$1, col + delta.$2);
  }

  @override
  List<Object?> get props => [row, col];
}
