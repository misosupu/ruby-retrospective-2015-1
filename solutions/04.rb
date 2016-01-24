SUITS = [:clubs, :diamonds, :hearts, :spades]

class Card
  attr_accessor :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{@rank.to_s.capitalize} of #{@suit.capitalize}"
  end

  def ==(other)
    @rank == other.rank && @suit == other.suit
  end

  def queen?
    @rank == :queen
  end

  def king?
    @rank == :king
  end
end

class GenericDeck
  include Enumerable
  RANKS = []

  def generate_deck
    self.class::RANKS.product(SUITS).map! { |rank, suit| Card.new(rank, suit) }
  end

  def initialize(deck = generate_deck)
    @deck = deck
  end

  def size
    @deck.length
  end

  def draw_top_card
    @deck.shift
  end

  def draw_bottom_card
    @deck.pop
  end

  def top_card
    @deck.first
  end

  def bottom_card
    @deck.last
  end

  def shuffle
    @deck.shuffle!
  end

  def to_s
    @deck.map(&:to_s).join("\n")
  end

  def sort
    @deck.sort! do |x, y|
      if (SUITS.index(y.suit) <=> SUITS.index(x.suit)) == 0
        self.class::RANKS.index(y.rank) <=> self.class::RANKS.index(x.rank)
      else
        SUITS.index(y.suit) <=> SUITS.index(x.suit)
      end
    end
  end

  def each(&block)
    @deck.each(&block)
  end
end

class Hand
  include Enumerable
  attr_accessor :cards

  def initialize(cards = [])
    @cards = cards
  end

  def get_suit(suit)
    @cards.select { |card| card.suit == suit }
  end

  def king_and_queen?(suits)
    suits.any? do |suite|
      current_suite = get_suit(suite)
      current_suite.any?(&:queen?) && current_suite.any?(&:king?)
    end
  end

  def to_s
    @cards.map(&:to_s).join("\n")
  end

  def size
    @cards.length
  end

  def each(&block)
    @cards.each(&block)
  end
end

class WarDeck < GenericDeck
  RANKS = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]
  DEAL_SIZE = 26

  def deal
    WarHand.new(@deck.pop(DEAL_SIZE))
  end
end

class WarHand < Hand
  def size
    @cards.length
  end

  def play_card
    @cards.delete_at(rand(0...@cards.length))
  end

  def allow_face_up?
    @cards.length <= 3
  end
end

class BeloteDeck < GenericDeck
  RANKS = [7, 8, 9, :jack, :queen, :king, 10, :ace]
  DEAL_SIZE = 8

  def deal
    BeloteHand.new(self.class::RANKS, @deck.pop(DEAL_SIZE))
  end
end

class BeloteHand < Hand
  def initialize(ranks, cards = [])
    @ranks = ranks
    super cards
  end

  def highest_of_suit(suit)
    get_suit(suit).sort do |x, y|
      @ranks.index(x.rank) <=> @ranks.index(y.rank)
    end.last
  end

  def belote?
    king_and_queen?(SUITS)
  end

  def identify_sequences(length)
    SUITS.any? do |suit|
      current_suit = get_suit(suit).map! { |card| @ranks.index card.rank }.sort!
      current_suit.each_cons(length).any? do |list|
        list == (list.first..list.last).to_a
      end
    end
  end

  def tierce?
    identify_sequences(3)
  end

  def quarte?
    identify_sequences(4)
  end

  def quint?
    identify_sequences(5)
  end

  def carre?(card_type)
    @cards.count { |card| card.rank == card_type } == 4
  end

  def carre_of_jacks?
    carre?(:jack)
  end

  def carre_of_nines?
    carre?(9)
  end

  def carre_of_aces?
    carre?(:ace)
  end
end

class SixtySixDeck < GenericDeck
  RANKS = [9, :jack, :queen, :king, 10, :ace]
  DEAL_SIZE = 6

  def deal
    SixtySixHand.new(@deck.pop(DEAL_SIZE))
  end
end

class SixtySixHand < Hand
  def twenty?(trump_suit)
    king_and_queen?(SUITS.select { |suit| suit != trump_suit })
  end

  def forty?(trump_suit)
    king_and_queen?([trump_suit])
  end
end
