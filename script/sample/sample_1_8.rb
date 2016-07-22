_SEND_ :base do
  _SET_ path: "./resource/bg_sample.png"
end

_SEND_ :img0 do
  _SET_ path: "./resource/char/B-1.png", x: 250
end

_SEND_ :img1 do
  _SET_ path: "./resource/char/B-2.png", x: 250, visible: false
end

_WAIT_ key_push: K_SPACE

_SEND_ :img0 do
  _MOVE_ 360, alpha: [255, 0]
end

_SEND_ :img1 do
  _SET_ visible: true
  _MOVE_ 360, alpha: [0,255]
end

_END_PAUSE_
