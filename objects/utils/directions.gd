extends Node

const isometric_angle = 27;

enum Directions {
    RIGHT = 0,
    UP_RIGHT = isometric_angle,
    UP = 90,
    LEFT_UP = 180 - isometric_angle,
    LEFT = 180,
    DOWN_LEFT = 180 + isometric_angle,
    DOWN = 270,
    RIGHT_DOWN = 360 - isometric_angle,
    ZERO = -1
}

static var DIRECTIONS = [
    Directions.RIGHT, 
    Directions.UP_RIGHT, 
    Directions.UP, 
    Directions.LEFT_UP, 
    Directions.LEFT, 
    Directions.DOWN_LEFT, 
    Directions.DOWN, 
    Directions.RIGHT_DOWN
]

static func direction_to_vector(dir: Directions):
    if dir == Directions.ZERO:
        return Vector2(0, 0)
    var angle = deg_to_rad(dir);
    return Vector2(cos(angle), sin(angle))

static func rectangular_vector_to_direction(vec_dir: Vector2):
    if vec_dir.x == 0 and vec_dir.y == 0:
        return Directions.ZERO
    elif vec_dir.x > 0 and vec_dir.y == 0:
        return Directions.RIGHT
    elif vec_dir.x > 0 and vec_dir.y < 0:
        return Directions.UP_RIGHT
    elif vec_dir.x == 0 and vec_dir.y < 0:
        return Directions.UP
    elif vec_dir.x < 0 and vec_dir.y < 0:
        return Directions.LEFT_UP
    elif vec_dir.x < 0 and vec_dir.y == 0:
        return Directions.LEFT
    elif vec_dir.x < 0 and vec_dir.y > 0:
        return Directions.DOWN_LEFT
    elif vec_dir.x == 0 and vec_dir.y > 0:
        return Directions.DOWN
    else:
        return Directions.RIGHT_DOWN
