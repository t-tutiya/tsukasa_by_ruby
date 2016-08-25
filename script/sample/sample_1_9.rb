_SEND_ :base do
  _SET_ path: "./resource/bg_sample.png"
end

_SEND_ :img0 do
  _SET_ path: "./resource/char/B-1.png", x: 250
end

_LOOP_ do
  _CHECK_INPUT_ key_push: K_SPACE do
    _BREAK_
  end
  _END_FRAME_
end

_TO_IMAGE_ :test0

_SEND_ :img0 do
  _SET_ path: "./resource/char/B-2.png"
end


_SEND_ :test0 do
  _MOVE_ 360, alpha: [255, 0]
end

_END_PAUSE_
_DELETE_ :test0
