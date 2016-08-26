_SEND_ :base do
  _SET_ path: "./resource/bg_sample.png"
end

_CREATE_ :DrawableLayout, id: :test0,
  x: 100, y: 100, width: 512, height: 512, z: 4000 do
  _CREATE_ :Image, path: "./resource/button_over.png", x: 100
  _CREATE_ :Image, path: "./resource/button_normal.png", y: 100
end

_SEND_ :test0 do
  _MOVE_ 180, alpha: [255,   0]
  _MOVE_ 360, alpha: [  0, 255]
end

_END_PAUSE_
_DELETE_ :test0
