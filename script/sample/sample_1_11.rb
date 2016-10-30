_SEND_ :text0 do
  _TEXT_ "ＸかＺのキーを押してください"
  _LINE_FEED_
end

_WAIT_ input:{key_down: [K_X,K_Z]}

_CHECK_INPUT_ key_down: [K_X] do
  _SEND_ :text0 do
    _TEXT_ "Ｘキーが押されました"
  end
end
_CHECK_INPUT_ key_down: [K_Z] do
  _SEND_ :text0 do
    _TEXT_ "Ｚキーが押されました"
  end
end

_END_PAUSE_
_SEND_ :text0 do
  _FLUSH_
end