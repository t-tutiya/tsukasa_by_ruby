_SEND_(:base) {_SET_ path: "./resource/bg_sample.png"}
_SEND_(:img0) {_SET_ path: "./resource/char/B-1.png", x: 250}

_LOOP_ do
  _CHECK_INPUT_ key_push: K_SPACE do
    _BREAK_
  end
  _END_FRAME_
end

_TO_IMAGE_ :test0 do 
  _CREATE_ :RuleShader, id: :rule0, vague: 40,
            path: "./resource/rule/horizontal_rule.png"
  _SET_ shader: :rule0
end

_SEND_(:base) {_SET_ path: "./resource/bg_test.jpg"}
_SEND_(:img0) {_SET_ path: "./resource/char/B-2.png"}

_SEND_ [:test0, :rule0] do
  _MOVE_ 240, counter:[0,255]
end

_END_PAUSE_
_DELETE_ :test0
