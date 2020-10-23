require 'nokogiri'
require 'json'
require 'set'

KINDS = {
  '財宝' => 'Treasure',
  '勝利点' => 'Victory',
  '呪い' => 'Curse',
  'アクション' => 'Action',
  'アタック' => 'Attack',
  'リアクション' => 'Reaction',
  '持続' => 'Duration',
  '褒賞' => 'Prize',
  '廃墟' => 'Ruins',
  'Command' => 'Command',
  '略奪者' => 'Looter',
  '避難所' => 'Shelter',
  '騎士' => 'Knight',
  'リザーブ' => 'Reserve',
  'トラベラー' => 'Traveller',
  'イベント' => 'Event',
  '城' => 'Castle',
  '集合' => 'Gathering',
  'ランドマーク' => 'Landmark',
  '幸運' => 'Fate',
  '夜行' => 'Night',
  '不運' => 'Doom',
  '家宝' => 'Heirloom',
  '精霊' => 'Spirit',
  'ゾンビ' => 'Zombie',
  '祝福' => 'Boon',
  '呪詛' => 'Hex',
  '状態' => 'State',
  'アーティファクト' => 'Artifact',
  'プロジェクト' => 'Project',
  '習性' => 'Way'
}.freeze

BASIC_CARDS = Set.new(%w[銅貨 銀貨 金貨 白金貨 屋敷 公領 属州 植民地 呪い])
SETS = {
  '基本' => 'Base',
  '陰謀' => 'Intrigue',
  '海辺' => 'Seaside',
  '錬金術' => 'Alchemy',
  '繁栄' => 'Prosperity',
  '収穫祭' => 'Cornucopia',
  '異郷' => 'Hinterlands',
  '暗黒時代' => 'DarkAge',
  'ギルド' => 'Guilds',
  '冒険' => 'Adventures',
  '帝国' => 'Empires',
  '夜想曲' => 'Nocturne',
  'ルネサンス' => 'Renaissance',
  '移動動物園' => 'Menagerie',
  'プロモ' => 'Promos'
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
  text.split('−').map { KINDS.fetch(_1) }
end

def parse_set(ja, text)
  return 'Basic' if BASIC_CARDS.include?(ja)

  SETS.fetch(text)
end

doc = Nokogiri::HTML.parse($stdin.read)

card_nodes = doc.css('tr.tr2, tr.tr3')
cards = card_nodes.map do |card_node|
  _, ja_node, kana_node, en_node, cost_node, kinds_node, set_node = card_node.children
  ja = ja_node.css('a').text

  {
    name: en_node.text,
    ja: ja,
    kana: kana_node.text,
    cost: parse_cost(cost_node.text),
    kinds: parse_kinds(kinds_node.text),
    set: parse_set(ja, set_node.text)
  }
end

puts JSON.pretty_generate(cards)
