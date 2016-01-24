def move(snake, direction)
  new_snake = snake.clone
  new_snake.shift
  grow(new_snake, direction)
end

def grow(snake, direction)
  new_snake = snake.clone
  head = new_snake[-1]
  new_snake.push(head.zip(direction).map { |coordinate| coordinate.inject(:+)})
end

def new_food(food, snake, dimensions)
  coordinates = food + snake
  field = (0..dimensions[:width] - 1).to_a.product(
      (0..dimensions[:width] - 1).to_a)
  field -= coordinates
  field.sample
end

def obstacle_ahead?(snake, direction, dimensions)
  next_position = snake[-1]
  next_position = next_position.zip(direction).map do |element|
    element.inject(:+)
  end
  snake.include?(next_position) or (next_position[0] < 0 or
      next_position[0] >= dimensions[:width]) or (next_position[1] < 0 or
      next_position[1] >= dimensions[:height])
end

def danger?(snake, direction, dimensions)
  obstacle_ahead?(snake, direction, dimensions) or
      obstacle_ahead?(move(snake, direction), direction, dimensions)
end
