import 'package:equatable/equatable.dart';
import 'direction.dart';

enum TileType {
  line,
  corner,
  tee,
  cross,
  deadEnd,
  source,
  empty
}

class Tile extends Equatable {
  final TileType type;
  final int rotation; // 0, 90, 180, 270
  final bool isFixed;
  final Direction? baseDirection;
  final bool isConnected;

  const Tile({
    required this.type,
    this.rotation = 0,
    this.isFixed = false,
    this.baseDirection,
    this.isConnected = false,
  });

  Tile copyWith({
    TileType? type,
    int? rotation,
    bool? isFixed,
    Direction? baseDirection,
    bool? isConnected,
  }) {
    return Tile(
      type: type ?? this.type,
      rotation: rotation ?? this.rotation,
      isFixed: isFixed ?? this.isFixed,
      baseDirection: baseDirection ?? this.baseDirection,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  Tile rotate() {
    if (isFixed) return this;
    return copyWith(rotation: (rotation + 90) % 360);
  }

  Set<Direction> get openings {
    Set<Direction> baseOpenings = {};

    switch (type) {
      case TileType.line:
        baseOpenings = {Direction.north, Direction.south};
        break;
      case TileType.corner:
        baseOpenings = {Direction.south, Direction.east};
        break;
      case TileType.tee:
        baseOpenings = {Direction.north, Direction.east, Direction.south};
        break;
      case TileType.cross:
        baseOpenings = {Direction.north, Direction.east, Direction.south, Direction.west};
        break;
      case TileType.deadEnd:
        // Cap tile — one opening pointing south at rotation 0
        baseOpenings = {Direction.south};
        break;
      case TileType.source:
        if (baseDirection != null) {
          baseOpenings = {baseDirection!};
        }
        break;
      case TileType.empty:
        baseOpenings = {};
        break;
    }

    return baseOpenings.map((dir) => dir.rotateClockwiseBy(rotation)).toSet();
  }

  @override
  List<Object?> get props => [type, rotation, isFixed, baseDirection, isConnected];
}
