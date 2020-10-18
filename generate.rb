require 'nokogiri'
require 'json'

doc = Nokogiri::HTML.parse($stdin.read)

card_nodes = doc.css('tr.tr2, tr.tr3')
cards = card_nodes.map do |card_node|
  _, ja_node, kana_node, en_node, cost_node, kinds_node, set_node = card_node.children

  {
    name: en_node.text,
    ja: ja_node.css('a').text,
    kana: kana_node.text,
    cost: cost_node.text,
    kinds: kinds_node.text,
    set: set_node.text
  }
end

puts JSON.pretty_generate(cards)
