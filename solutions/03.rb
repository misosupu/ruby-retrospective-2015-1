module DrunkenMathematician
  def is_prime?(number)
    if number == 1 or number == 2
      return true
    end
    i = 2
    limit = Math.sqrt(number).ceil
    while i <= limit do
      if number % i == 0
        return false
      end
      i += 1
    end
    true
  end

  def meaningless(n)
    rationals = RationalSequence.new(n).to_a
    first = rationals.select { |rat| is_prime?(rat.numerator) or is_prime?(rat.denominator) }
    second = rationals.select { |rat| not is_prime?(rat.numerator) and
        not is_prime?(rat.denominator) }
    Rational(first.reduce(:*) || 1, second.reduce(:*) || 1)
  end

  def aimless(n)
    primes = PrimeSequence.new(n).to_a
    numerators = []
    denominators = []
    primes.each_with_index do |number, index|
      if index.even?
        numerators.push(number)
      else
        denominators.push(number)
      end
    end
    if n.odd?
      Rational(numerators[-1], 1) +
          numerators.zip(denominators).map { |rat| Rational(rat[0], rat[1]) }.reduce(:+)
    else
      numerators.zip(denominators).map { |rat| Rational(rat[0], rat[1]) }.reduce(:+)
    end
  end

  def worthless(n)
    nth_fibonacci = FibonacciSequence.new(n).to_a[-1] || 0
    i = 1
    while RationalSequence.new(i).to_a.reduce(:+) <= nth_fibonacci do
      i += 1
    end
    RationalSequence.new(i - 1).to_a
  end

  module_function :is_prime?
  module_function :meaningless
  module_function :aimless
  module_function :worthless
end

class RationalSequenceElement
  def initialize(first, second)
    @first = first
    @second = second
  end

  attr_accessor :first
  attr_accessor :second

  def can_be_simplified
    @first.gcd(@second) != 1
  end
end

class RationalSequence
  include Enumerable

  def initialize(limit)
    @limit = limit
    @current_number = RationalSequenceElement.new(1, 1)
  end

  def generate_next(number)
    if ((number.first + number.second) % 2).even?
      if number.second != 1
        number = RationalSequenceElement.new(number.first + 1, number.second - 1)
      else
        number = RationalSequenceElement.new(number.first + 1, number.second)
      end
    else # odd
      if number.first != 1
        number = RationalSequenceElement.new(number.first - 1, number.second + 1)
      else
        number = RationalSequenceElement.new(number.first, number.second + 1)
      end
    end
  end

  def each
    # if the sum of indices is odd - x decreases and y increases
    # if the sum is even - x increases and y decreases
    current_index, current_number = 0, RationalSequenceElement.new(1, 1)

    while current_index != @limit
      yield Rational(current_number.first, current_number.second)
      current_number = generate_next(current_number)
      while current_number.can_be_simplified do
        current_number = generate_next(current_number)
      end
      current_index += 1
    end
  end
end


class PrimeSequence
  include Enumerable
  include DrunkenMathematician

  def initialize(limit)
    @limit = limit
  end

  def each
    current_index, current_number = 0, 2

    while current_index != @limit
      yield current_number
      current_number += 1
      while not is_prime?(current_number) do
        current_number += 1
      end
      current_index += 1
    end
  end
end

class FibonacciSequence
  include Enumerable

  def initialize(limit, first=0, second=1)
    @limit = limit
    @first = first
    @second = second
  end

  def each
    current_index, current, previous = 0, @second, @first

    while current_index < @limit
      yield current
      current, previous = current + previous, current
      current_index += 1
    end
  end
end
