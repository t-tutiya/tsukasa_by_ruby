#! ruby -E utf-8

_CHECK_ [:equal], equal: { test1: true} do
  _EVAL_ "pp 'test1 A ng'"
end

_SET_ :_USER_DATA_, test1: false

_CHECK_ [:equal], equal: { test1: true} do
  _EVAL_ "pp 'test1 B ng'"
end

_SET_ :_USER_DATA_, test1: true

_CHECK_ [:equal], equal: { test1: true} do
  _EVAL_ "pp 'test1 C ok'"
end

_CHECK_ [:not_equal], not_equal: { test2: 1} do
  _EVAL_ "pp 'test2 A ok'"
end

_SET_ :_USER_DATA_, test2: true

_CHECK_ [:not_equal], not_equal: { test2: 1} do
  _EVAL_ "pp 'test2 B ok'"
end

_SET_ :_USER_DATA_, test2: 1

_CHECK_ [:not_equal], not_equal: { test2: 1} do
  _EVAL_ "pp 'test2 C ng'"
end

_CHECK_ [:null], null: [:test3] do
  _EVAL_ "pp 'test3 A ok'"
end

_SET_ :_USER_DATA_, test3: false

_CHECK_ [:null], null: :test3 do
  _EVAL_ "pp 'test3 B ng'"
end

_SET_ :_USER_DATA_, test3: true

_CHECK_ [:null], null: :test3 do
  _EVAL_ "pp 'test3 C ng'"
end

_CHECK_ [:not_null], not_null: [:test4] do
  _EVAL_ "pp 'test4 A ng'"
end

_SET_ :_USER_DATA_, test4: true

_CHECK_ [:not_null], not_null: :test4 do
  _EVAL_ "pp 'test4 B ok'"
end

_SET_ :_USER_DATA_, test4: 1

_CHECK_ [:not_null], not_null: :test4 do
  _EVAL_ "pp 'test4 C ok'"
end

_CHECK_ [:not_null], type: :_GLOBAL_DATA_, not_null: [:test5] do
  _EVAL_ "pp 'test5 A ng'"
end

_SET_ :_GLOBAL_DATA_, test5: true

_CHECK_ [:not_null], type: :_GLOBAL_DATA_, not_null: [:test5] do
  _EVAL_ "pp 'test5 B ok'"
end

_SET_ :_GLOBAL_DATA_, test5: 1

_CHECK_ [:not_null], type: :_GLOBAL_DATA_, not_null: [:test5] do
  _EVAL_ "pp 'test5 C ok'"
end

