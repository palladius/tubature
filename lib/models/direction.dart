enum Direction {
  north,
  east,
  south,
  west;

  Direction get opposite {
    switch (this) {
      case Direction.north:
        return Direction.south;
      case Direction.east:
        return Direction.west;
      case Direction.south:
        return Direction.north;
      case Direction.west:
        return Direction.east;
    }
  }

  Direction rotateClockwiseBy(int degrees) {
    int steps = (degrees ~/ 90) % 4;
    Direction current = this;
    for (int i = 0; i < steps; i++) {
      current = current._rotateOnce;
    }
    return current;
  }
  
  Direction get _rotateOnce {
    switch (this) {
      case Direction.north:
        return Direction.east;
      case Direction.east:
        return Direction.south;
      case Direction.south:
        return Direction.west;
      case Direction.west:
        return Direction.north;
    }
  }

  (int, int) get delta {
    switch (this) {
      case Direction.north:
        return (-1, 0);
      case Direction.east:
        return (0, 1);
      case Direction.south:
        return (1, 0);
      case Direction.west:
        return (0, -1);
    }
  }
}
