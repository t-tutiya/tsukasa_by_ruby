_SEND_ :base do
  _SET_ path: "./resource/bg_sample.png"
end

_SEND_ :img0 do
  _SET_ path: "./resource/button_over.png", x: 200, y: 100
  _MOVE_ 180, alpha: 0
  _MOVE_ 360, alpha: 255
end

_SEND_ :img1 do
  _SET_ path: "./resource/button_normal.png", x: 100, y: 200
  _MOVE_ 180, alpha: 0
  _MOVE_ 360, alpha: 255
end

_END_PAUSE_
