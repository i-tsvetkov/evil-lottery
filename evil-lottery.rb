WIN_COMB_SIZE  = [2, 3, 4, 5, 6]
WIN_COMB_PRICE = { 2 => 1, 3 => 10, 4 => 1000, 5 => 100_000, 6 => 1_000_000 }
COMB_NUMBERS   = (1 .. 47).to_a
COMB_SIZE      = 6

def load_combinations(file)
  combinations = {}
  tickets = File.readlines(file).map(&:strip).map{ |l| l.split("\s").map(&:to_i).sort }
  tickets.each do |t|
    WIN_COMB_SIZE.each do |k|
      t.combination(k).each do |c|
        combinations[c] = combinations.key?(c) ? combinations[c] + 1 : 1
      end
    end
  end
  return combinations
end

# NOTE: the price is calculated a little bit higher than the real price
#       but this does not make a difference to the algorithm
def ticket_price(ticket, combinations)
  price = 0
  WIN_COMB_SIZE.each do |k|
    ticket.sort.combination(k).each do |c|
      price += combinations.key?(c) ? WIN_COMB_PRICE[c.size] * combinations[c] : 0
    end
  end
  return price
end

def get_evil_combination(combinations, acceptable_price = 0)
  minimum_price, ticket = 999_999_999_999, nil
  COMB_NUMBERS.shuffle.combination(COMB_SIZE).each do |c|
    price = ticket_price(c, combinations)
    minimum_price, ticket = price, c if price < minimum_price
    break if minimum_price <= acceptable_price
  end
  return ticket
end

def find_evil_combination(combinations, try_limit = 10000, acceptable_price = 0)
  try_limit.times do
    ticket = COMB_NUMBERS.sample(COMB_SIZE)
    price  = ticket_price(ticket, combinations)
    return ticket if price <= acceptable_price
  end
  return nil
end

def get_random_tickets(number)
  (1 .. number).map{ COMB_NUMBERS.sample(COMB_SIZE) }
end
