_LOOP_ 3 do
  _LOOP_ 3 do
    _SEND_ :text0 do
      _TEXT_ "＊"
    end
  end
  _SEND_ :text0 do
    _LINE_FEED_
  end
end
_END_PAUSE_
_SEND_ :text0 do
  _FLUSH_
end

