_SET_ [:_ROOT_, :_TEMP_], name_a: "土屋"
_SEND_ :text0 do
  _TEXT_ _TEMP_: :name_a
  _TEXT_ "「_SET_コマンドはデータストアに値を格納します」"
end
_END_PAUSE_

_GET_ :name_a,  control: [:_ROOT_, :_TEMP_] do |name_a:|
  _SET_ [:_ROOT_, :_TEMP_], name_b: name_a
end
_SEND_ :text0 do
  _FLUSH_
  _TEXT_ _TEMP_: :name_b
  _TEXT_ "「_GET_コマンドはデータストアから値を取得します」"
end
_END_PAUSE_
_SEND_ :text0 do
  _FLUSH_
end
