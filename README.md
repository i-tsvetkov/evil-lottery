# Evil Lottery
Скриптове, които намират тази комбинация/и, при която ще има
минимална загуба съответно минимални печалби.

### Пример
```ruby
require './evil-lottery.rb'

lottery = EvilLottery.new(6, (1..49).to_a, {3=>10, 4=>100, 5=>100_000, 6=>1_000_000})

lottery.load_combinations('./tickets.txt')

puts lottery.get_evil_combination.to_s

```

### API
```ruby
# Конструктор на лотарията.
# comb_size      - размера на комбинациите
# comb_numbers   - числата използвани в комбинациите
# win_comb_price - хеш, в който ключовете са размерите
#                  на печелившите комбинации, а стойностите
#                  са печалбата за всяка от тях.
EvilLottery.new(comb_size, comb_numbers, win_comb_price)

# зарежда играните комбинации от файл
# всяка комбинация трябва да е сама на ред
# и числата трябва да са разделени с интервал
EvilLottery.load_combinations(file)

# връща първата намерена комбинацията
# при която загубата ще бъде <= acceptable_price
# ако не намери такава комбинация връща тази с минимална загуба
EvilLottery.get_evil_combination(acceptable_price = 0)

# търси на случаен принцип комбинация
# при която загубата ще бъде <= acceptable_price
# try_limit е броя опити които да се направят
EvilLottery.find_evil_combination(try_limit = 10000, acceptable_price = 0)
```

### TODO
* Търсене на комбинациите в паралел чрез JRuby или Rubinius?

