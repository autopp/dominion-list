require 'nokogiri'
require 'json'

def parse_cost(text)

  text = text[0...-1] if text.end_with?('*')
  if text.end_with?('+')
    text = text[0...-1]
    overpay = true
  end

  coin = potion = debt = 0
  text.split('・').each do |cost|
    case cost
    when /^\$\d+$/
      coin = cost[1..-1].to_i
    when /^\d+P/
      potion = cost[0...-1].to_i
    when /^\d+D$/
      debt = cost[0...-1].to_i
    when /-/
      # skip
    else
      raise "cannot parse cost '#{text}'"
    end
  end

  {
    coin: coin,
    potion: potion,
    debt: debt,
    overpay: overpay || false
  }
end

doc = Nokogiri::HTML.parse($stdin.read)

card_nodes = doc.css('tr.tr2, tr.tr3')
cards = card_nodes.map do |card_node|
  _, ja_node, kana_node, en_node, cost_node, kinds_node, set_node = card_node.children

  {
    name: en_node.text,
    ja: ja_node.css('a').text,
    kana: kana_node.text,
    cost: parse_cost(cost_node.text),
    kinds: kinds_node.text,
    set: set_node.text
  }
end

puts JSON.pretty_generate(cards)
