require 'nokogiri'
require 'json'
require 'set'

KINDS = {
  '財宝' => 'treasure',
  '勝利点' => 'victory',
  '呪い' => 'curse',
  'アクション' => 'action',
  'アタック' => 'attack',
  'リアクション' => 'reaction',
  '持続' => 'duration',
  '褒賞' => 'prize',
  '廃墟' => 'ruins',
  'Command' => 'command',
  '略奪者' => 'looter',
  '避難所' => 'shelter',
  '騎士' => 'knight',
  'リザーブ' => 'reserve',
  'トラベラー' => 'traveller',
  'イベント' => 'event',
  '城' => 'castle',
  '集合' => 'gathering',
  'ランドマーク' => 'landmark',
  '幸運' => 'fate',
  '夜行' => 'night',
  '不運' => 'doom',
  '家宝' => 'heirloom',
  '精霊' => 'spirit',
  'ゾンビ' => 'zombie',
  '祝福' => 'boon',
  '呪詛' => 'hex',
  '状態' => 'state',
  'アーティファクト' => 'artifact',
  'プロジェクト' => 'project',
  '習性' => 'way'
}.freeze

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

def parse_kinds(text)
  text.split('－').map { KINDS.fetch(_1) }
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
    kinds: parse_kinds(kinds_node.text),
    set: set_node.text
  }
end

puts JSON.pretty_generate(cards)
