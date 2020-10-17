require 'rexml/document'

doc = REXML::Document.new($stdin.read)

REXML::XPath.each(doc, '//tr[contains(@class, "tr2") or contains(@class, "tr3")]') do |e|
  puts e.children[1].children.first.text
end
