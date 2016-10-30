_CREATE_ :Sound, path: "./resource/music/easygoing.ogg", id: :test0
_SEND_ :text0 do
  _TEXT_ "初期化終了。スペースキーを押してください"
end
_END_PAUSE_
_SEND_ :test0 do
  _PLAY_ 0, fadetime: 5
end
_SEND_ :text0 do
  _FLUSH_
  _TEXT_ "無限ループ中。スペースキーを押してください"
end
_END_PAUSE_
_SEND_ :test0 do
  _STOP_ fadetime: 5
end

_WAIT_ count:5*60
_SEND_ :text0 do
  _FLUSH_
end
_DELETE_ :test0
