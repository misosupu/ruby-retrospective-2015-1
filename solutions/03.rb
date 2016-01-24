module DrunkenMathematician
  def prime?(number)
    return true if number == 1
    2.upto(Math.sqrt(number).ceil).all? { |i| number % i != 0 }
  end

  def meaningless(n)
    rationals = RationalSequence.new(n).to_a
    first = rationals.select do |rat|
      prime?(rat.numerator) || prime?(rat.denominator)
    end
    second = rationals.select do |rat|
      ! prime?(rat.numerator) && ! prime?(rat.denominator)
    end
    Rational(first.reduce(:*) || 1, second.reduce(:*) || 1)
  end

  def aimless(n)
    primes = PrimeSequence.new(n).to_a
    rationals = []
    primes.each_slice(2) do |numerator, denominator|
      denominator = 1 if denominator.nil?
      rationals << Rational(numerator, denominator)
    end
    rationals.reduce(:+)
  end

  def worthless(n)
    nth_fibonacci = FibonacciSequence.new(n).to_a[-1] || 0
    i = 1
    i += 1 while RationalSequence.new(i).to_a.reduce(:+) <= nth_fibonacci
    RationalSequence.new(i - 1).to_a
  end

  module_function :prime?
  module_function :meaningless
  module_function :aimless
  module_function :worthless
end

class RationalSequence
  include Enumerable
  ELEMENT = Struct.new(:numerator, :denominator)

  def initialize(limit)
    @limit = limit
    @current_number = ELEMENT.new(1, 1)
  end

  def generate_next(number)
    if ((number.numerator + number.denominator) % 2).even?
      if number.denominator != 1
        ELEMENT.new(number.numerator + 1, number.denominator - 1)
      else
        ELEMENT.new(number.numerator + 1, number.denominator)
      end
    else # odd
      if number.numerator != 1
        ELEMENT.new(number.numerator - 1, number.denominator + 1)
      else
        ELEMENT.new(number.numerator, number.denominator + 1)
      end
    end
  end

  def each
    # if the sum of indices is odd - x decreases and y increases
    # if the sum is even - x increases and y decreases
    current_index, current_number = 0, ELEMENT.new(1, 1)

    while current_index != @limit
      yield Rational(current_number.numerator, current_number.denominator)
      current_number = generate_next(current_number)
      until simplified?(current_number)
        current_number = generate_next(current_number)
      end
      current_index += 1
    end
  end

  private

  def simplified?(rational)
    rational.numerator.gcd(rational.denominator) == 1
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
      current_number += 1 until prime?(current_number)
      current_index += 1
    end
  end
end

class FibonacciSequence
  include Enumerable

  def initialize(limit, first: 1, second: 1)
    @limit = limit
    @first = first
    @second = second
  end

  def each
    current_index, current, previous = 0, @second, @first
    while current_index < @limit
      yield previous
      current, previous = current + previous, current
      current_index += 1
    end
  end
end
