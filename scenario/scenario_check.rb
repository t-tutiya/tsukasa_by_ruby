#! ruby -E utf-8

_CHECK_ [:equal], key: :test1, val: true do
  _EVAL_ "pp 'test1 A'"
end

_SET_ :_USER_DATA_, test1: false

_CHECK_ [:equal], key: :test1, val: true do
  _EVAL_ "pp 'test1 B'"
end

_SET_ :_USER_DATA_, test1: true

_CHECK_ [:equal], key: :test1, val: true do
  _EVAL_ "pp 'test1 C'"
end

_CHECK_ [:not_equal], key: :test2, val: 1 do
  _EVAL_ "pp 'test2 A'"
end

_SET_ :_USER_DATA_, test2: true

_CHECK_ [:not_equal], key: :test2, val: 1 do
  _EVAL_ "pp 'test2 B'"
end

_SET_ :_USER_DATA_, test2: 1

_CHECK_ [:not_equal], key: :test2, val: 1 do
  _EVAL_ "pp 'test2 C'"
end

_CHECK_ [:nil], key: :test3 do
  _EVAL_ "pp 'test3 A'"
end

_SET_ :_USER_DATA_, test3: false

_CHECK_ [:nil], key: :test3 do
  _EVAL_ "pp 'test3 B'"
end

_SET_ :_USER_DATA_, test3: true

_CHECK_ [:nil], key: :test3 do
  _EVAL_ "pp 'test3 C'"
end

_CHECK_ [:not_nil], key: :test4 do
  _EVAL_ "pp 'test4 A'"
end

_SET_ :_USER_DATA_, test4: true

_CHECK_ [:not_nil], key: :test4 do
  _EVAL_ "pp 'test4 B'"
end

_SET_ :_USER_DATA_, test4: 1

_CHECK_ [:not_nil], key: :test2 do
  _EVAL_ "pp 'test4 C'"
end

