# Evil Lottery
Скриптове, които намират тази комбинация/и, при която ще има
минимална загуба съответно минимални печалби.

### Пример
```ruby
require './evil-lottery.rb'

combs = load_combinations('./tickets.txt')

puts get_evil_combination(combs).to_s

```

### API
```ruby
# зарежда играните комбинации от файл
# всяка комбинация трябва да е сама на ред
# и числата трябва да са разделени с интервал
load_combinations(file)

# връща първата намерена комбинацията
# при която загубата ще бъде <= acceptable_price
# ако не намери такава комбинация връща тази с минимална загуба
# combinations са играните комбинации
get_evil_combination(combinations, acceptable_price = 0)

# търси на случаен принцип комбинация
# при която загубата ще бъде <= acceptable_price
# combinations са играните комбинации,
# try_limit е броя опити които да се направят
find_evil_combination(combinations, try_limit = 10000, acceptable_price = 0)
```

### TODO
* Създаване на клас вместо използване на константи
* Преименуване на някои неща
* Търсене на комбинациите в паралел чрез JRuby или Rubinius?

