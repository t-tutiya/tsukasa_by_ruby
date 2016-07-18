_SEND_ :base do
  _SET_ file_path: "./resource/bg_sample.png"
end

_SEND_ :img0 do
  _SET_ file_path: "./resource/char/B-1.png", x: 250
end

_WAIT_ key_push: K_SPACE

_TO_IMAGE_ :test0

_SEND_ :img0 do
  _SET_ file_path: "./resource/char/B-2.png"
end


_SEND_ :test0 do
  _MOVE_ 360, alpha: [255, 0]
end

_END_PAUSE_
_DELETE_ :test0
