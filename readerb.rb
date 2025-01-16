require 'erb'

meaning_of_life = 42

question = "THew answer of the ultimate question of life is <%= meaning_of_life %> "

puts question

template = ERB.new question

puts template.result(binding)