#! ruby -E utf-8

_CHECK_ [:equal], key: :test1, val: true do
  _EVAL_ "pp 'test1 A'"
end

_SET_DATA_ key: :test1, val: false

_CHECK_ [:equal], key: :test1, val: true do
  _EVAL_ "pp 'test1 B'"
end

_SET_DATA_ key: :test1, val: true

_CHECK_ [:equal], key: :test1, val: true do
  _EVAL_ "pp 'test1 C'"
end

_CHECK_ [:not_equal], key: :test2, val: 1 do
  _EVAL_ "pp 'test2 A'"
end

_SET_DATA_ key: :test2, val: true

_CHECK_ [:not_equal], key: :test2, val: 1 do
  _EVAL_ "pp 'test2 B'"
end

_SET_DATA_ key: :test2, val: 1

_CHECK_ [:not_equal], key: :test2, val: 1 do
  _EVAL_ "pp 'test2 C'"
end

_CHECK_ [:nil], key: :test3 do
  _EVAL_ "pp 'test3 A'"
end

_SET_DATA_ key: :test3, val: false

_CHECK_ [:nil], key: :test3 do
  _EVAL_ "pp 'test3 B'"
end

_SET_DATA_ key: :test3, val: true

_CHECK_ [:nil], key: :test3 do
  _EVAL_ "pp 'test3 C'"
end

_CHECK_ [:not_nil], key: :test4 do
  _EVAL_ "pp 'test4 A'"
end

_SET_DATA_ key: :test4, val: true

_CHECK_ [:not_nil], key: :test4 do
  _EVAL_ "pp 'test4 B'"
end

_SET_DATA_ key: :test4, val: 1

_CHECK_ [:not_nil], key: :test2 do
  _EVAL_ "pp 'test4 C'"
end

