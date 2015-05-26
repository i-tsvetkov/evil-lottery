class EvilLottery
  def initialize(comb_size, comb_numbers, win_comb_price)
    @comb_size      = comb_size
    @comb_numbers   = comb_numbers
    @win_comb_price = win_comb_price
  end

  def load_combinations(file)
    @combinations = {}
    tickets = File.readlines(file).map(&:strip).map{ |l| l.split("\s").map(&:to_i).sort }
    @combinations[:maximum_price] = tickets.size * @win_comb_price.values.max
    tickets.each do |t|
      @win_comb_price.keys.each do |k|
        t.combination(k).each do |c|
          @combinations[c] = @combinations.key?(c) ? @combinations[c] + 1 : 1
        end
      end
    end
    return @combinations
  end

  def choose(n, k)
    ((n - k + 1) .. n).reduce(:*) / (2 .. k).reduce(:*)
  end

  def ticket_price(ticket)
    price = 0
    combs = {}
    @win_comb_price.keys.each do |k|
      combs[k] = 0
      ticket.sort.combination(k).each do |c|
        combs[k] += @combinations.key?(c) ? @combinations[c] : 0
      end
    end

    combs.keys.sort.reverse.each do |k_one|
      combs.keys.select{ |k| k < k_one }.sort.reverse.each do |k_two|
        combs[k_two] -= combs[k_one] * choose(k_one, k_two)
      end
    end

    combs.each do |k, v|
      price += v * @win_comb_price[k]
    end

    return price
  end

  def get_evil_combination(acceptable_price = 0)
    minimum_price, ticket = @combinations[:maximum_price], nil
    @comb_numbers.shuffle.combination(@comb_size).each do |c|
      price = ticket_price(c)
      minimum_price, ticket = price, c if price < minimum_price
      break if minimum_price <= acceptable_price
    end
    return ticket
  end

  def find_evil_combination(try_limit = 10000, acceptable_price = 0)
    try_limit.times do
      ticket = @comb_numbers.sample(@comb_size)
      price  = ticket_price(ticket)
      return ticket if price <= acceptable_price
    end
    return nil
  end

  def get_all_evil_combinations
    @comb_numbers.combination(@comb_size).map do |c|
      { price: ticket_price(c), combination: c }
    end.sort_by{ |c| c[:price] }
  end

  def get_random_tickets(number)
    number.times.map{ @comb_numbers.sample(@comb_size) }
  end
end
