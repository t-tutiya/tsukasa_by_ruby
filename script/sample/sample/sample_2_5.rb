_SEND_(:base) {_SET_ path: "./resource/bg_sample.png"}
_SEND_(:img0) {_SET_ path: "./resource/char/B-1.png", x: 250}

_WAIT_ input:{key_push: K_SPACE}

_TO_IMAGE_ :test0, width: 1024, height: 600 do 
  _CREATE_ :RuleTransition, id: :rule0, vague: 40,
            path: "./resource/rule/horizontal_rule.png"
  _GET_ :shader, control: :rule0 do |shader:|
    _SET_ shader: shader
  end
end

_SEND_(:base) {_SET_ path: "./resource/bg_test.jpg"}
_SEND_(:img0) {_SET_ path: "./resource/char/B-2.png"}

_SEND_ [:test0, :rule0] do
  _MOVE_ 240, counter:[0,255]
end

_END_PAUSE_
_DELETE_ :test0
