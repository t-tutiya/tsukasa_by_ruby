_CREATE_ :DrawableLayout, id: :test0, width: 800, height: 600 do
  _CREATE_ :Image, path: "./resource/bg_test.jpg"
  _CREATE_ :Image, path: "./resource/char/B-1.png", x: 250
end

_CREATE_ :Image, id: :test1, path: "./resource/bg_sample.png" do
  _CREATE_ :RuleTransition, id: :rule0, vague: 40,
            path: "./resource/rule/horizontal_rule.png"
  _GET_ :shader, control: :rule0 do |shader:|
    _SET_ shader: shader
  end
end

_WAIT_ input: {key_push: K_SPACE, mouse: :push}

_SEND_ :test1 do
  _SEND_ :rule0 do
    _MOVE_ 240, counter:[0,255]
    _DELETE_
  end

  _WAIT_ count: 240
  _DELETE_
end

_END_PAUSE_
_DELETE_ :test0
