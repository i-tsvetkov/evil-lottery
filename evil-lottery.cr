class EvilLottery
  def initialize(@comb_size, @comb_numbers, @win_comb_price)
    @combinations = Hash(Array(Int32), Int32).new(0)
    @ks = @win_comb_price.keys.sort.reverse
    @n = @ks.size - 1
    @choose = {} of Array(Int32) => Int32
    @ks.combinations(2).each do |c|
      @choose[c] = choose(c[0], c[1])
    end
  end

  def load_combinations(file)
    tickets = File.read_lines(file).map(&.strip).map{ |l| l.split(/\s+/).map(&.to_i).sort }
    tickets.each do |t|
      @win_comb_price.keys.each do |k|
        t.combinations(k).each do |c|
          @combinations[c] += 1
        end
      end
    end
    return @combinations
  end

  def choose(n, k)
    mul = ->(a : Int32, b : Int32) { a * b }
    ((n - k + 1) .. n).reduce(&mul) / (2 .. k).reduce(&mul)
  end

  def ticket_price(ticket)
    price = 0
    combs = Hash(Int32, Int32).new(0)
    ticket.sort!
    @win_comb_price.keys.each do |k|
      ticket.combinations(k).each do |c|
        combs[k] += @combinations[c]
      end
    end

    0.upto(@n).each do |i|
      (i + 1).upto(@n).each do |j|
        combs[@ks[j]] -= combs[@ks[i]] * @choose[[@ks[i], @ks[j]]]
      end
    end

    combs.each do |k, v|
      price += v * @win_comb_price[k]
    end

    return price
  end

  def get_evil_combination(acceptable_price = 0)
    minimum_price, ticket = Float64::INFINITY, nil
    @comb_numbers.shuffle.combinations(@comb_size).each do |c|
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
    @comb_numbers.combinations(@comb_size).map do |c|
      { price: ticket_price(c), combination: c }
    end.sort_by{ |c| c[:price] }
  end

  def get_random_tickets(number)
    number.times.map{ @comb_numbers.sample(@comb_size) }
  end
end
