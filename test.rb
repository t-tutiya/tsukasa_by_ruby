require_relative "system/tks_parser.rb"

parser = TKSParser.new
replacer = TKSParser::Replacer.new

=begin
output = parser.parse <<-EOF
@test 3
@   test  5,5
テスト文字列
テスト文字列[pause]テスト文字列[pause]
テスト文字列
EOF

puts output

puts replacer.apply(output).flatten.join("\n").encode("Windows-31J")
=end
puts replacer.apply(parser.parse(File.read("scenario/tks_test.txt", encoding: "UTF-8"))).flatten.join("\n").encode("Windows-31J")
