def move(snake, direction)
  grow(snake.clone, direction).drop(1)
end

def grow(snake, direction)
  new_snake = snake.clone
  new_snake.push([new_snake.last.first + direction.first,
                  new_snake.last.last + direction.last])
end

def new_food(food, snake, dimensions)
  coordinates = food + snake
  field = (0..dimensions[:width] - 1).to_a.product(
    (0..dimensions[:width] - 1).to_a)
  field -= coordinates
  field.sample
end

def obstacle_ahead?(snake, direction, dimensions)
  next_position = grow(snake.clone, direction).last
  intersects_body?(snake, next_position) ||
    intersects_border?(next_position, dimensions)
end

def danger?(snake, direction, dimensions)
  obstacle_ahead?(snake, direction, dimensions) ||
    obstacle_ahead?(move(snake, direction), direction, dimensions)
end

def intersects_body?(snake, position)
  snake.include?(position)
end

def intersects_border?(position, dimensions)
  (position.first >= dimensions[:width] || position.first < 0) ||
    (position.last >= dimensions[:height] || position.last < 0)
end
