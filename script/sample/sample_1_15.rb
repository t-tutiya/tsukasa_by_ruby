_SEND_ :text0 do
  _TEXT_ "ＸかＺのキーを押してください"
  _LINE_FEED_
end

_WAIT_ input:{key_down: [K_X,K_Z]}
_CHECK_INPUT_ key_down: [K_X] do
	_SET_ [:_ROOT_, :_SYSTEM_], data0: K_X
end
_CHECK_INPUT_ key_down: [K_Z] do
	_SET_ [:_ROOT_, :_SYSTEM_], data0: K_Z
end

_SYSTEM_SAVE_ "./datastore/system_data.dat"
_END_FRAME_

_SET_ [:_ROOT_, :_SYSTEM_], data0: "dummy"

_SYSTEM_LOAD_ "./datastore/system_data.dat"
_END_FRAME_

_CHECK_ [:_ROOT_, :_SYSTEM_], equal: {data0: K_X} do
  _SEND_ :text0 do
    _TEXT_ "Ｘキーが押されました"
  end
end
_CHECK_ [:_ROOT_, :_SYSTEM_], equal: {data0: K_Z} do
  _SEND_ :text0 do
    _TEXT_ "Ｚキーが押されました"
  end
end

_END_PAUSE_
_SEND_ :text0 do
  _FLUSH_
end
