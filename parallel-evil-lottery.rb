require './evil-lottery.rb'

class ParallelEvilLottery < EvilLottery
  def get_evil_combination(acceptable_price = 0)
    combinations = get_all_combinations.shuffle
    ticket_found = false
    threads = @cpu_count.times.map do |i|
      Thread.new do
        minimum_price, ticket = Float::INFINITY, nil
        i.step(combinations.size - 1, @cpu_count).each do |index|
          break if ticket_found
          t = combinations[index]
          price = ticket_price(t)
          minimum_price, ticket = price, t if price < minimum_price
          ticket_found = true if minimum_price <= acceptable_price
        end
        { price: minimum_price, ticket: ticket }
      end
    end
    threads.map(&:value).min_by{ |t| t[:price] }[:ticket]
  end

  def find_evil_combination(try_limit = 10000, acceptable_price = 0)
    parts = [try_limit / @cpu_count] * @cpu_count
    (try_limit % @cpu_count).times { |i| parts[i] += 1 }
    ticket_found = false
    threads = @cpu_count.times.map do |i|
      Thread.new do
        ticket, price = nil, Float::INFINITY
        parts[i].times do
          break if ticket_found
          ticket = @comb_numbers.sample(@comb_size)
          price  = ticket_price(ticket)
          ticket_found = true if price <= acceptable_price
        end
        ticket_found ? { ticket: ticket, price: price } : nil
      end
    end
    result = threads.map(&:value).compact
    result.empty? ? nil : result.min_by{ |t| t[:price] }[:ticket]
  end

  def get_all_combinations
    @all_combinations ||= @comb_numbers.combination(@comb_size).to_a
  end

  def set_cpu_count(cpu_count)
    @cpu_count = cpu_count
  end

  def get_random_tickets(number)
    fake_array = Array.new
    fake_array.define_singleton_method(:size){ number }
    pmap(fake_array, @cpu_count) do
      @comb_numbers.sample(@comb_size)
    end
  end

  def get_all_evil_combinations
    result = pmap(get_all_combinations, @cpu_count) do |c|
      { price: ticket_price(c), combination: c }
    end
    mergesort(result, @cpu_count) { |c| c[:price] }
  end

private

  def pmap(array, cpu_count, &block)
    cpu_count.times.map do |i|
      Thread.new do
        i.step(array.size - 1, cpu_count).map do |index|
          yield array[index]
        end
      end
    end.flat_map(&:value)
  end

  def mergesort(arr, cpu_num, &block)
    return arr if arr.size <= 1
    return arr.sort_by(&block) if cpu_num < 2
    left  = Thread.new { mergesort(arr[0, arr.size / 2], cpu_num / 2, &block) }
    right = mergesort(arr[arr.size / 2, arr.size], cpu_num / 2, &block)
    merge(left.value, right, &block)
  end

  def merge(left, right, &block)
    result = []
    until left.empty? or right.empty?
      result << (yield(left.first) <= yield(right.first) ? left.shift : right.shift)
    end
    result.concat(left).concat(right)
  end
end

