def test
  puts "test"
end

alias test2 test

test

test2

def test
  puts "new test"
end

test

test2

alias test3 test

alias test4 test2

test

test2

test3

test4

alias test test3

alias test2 test4

test

test2