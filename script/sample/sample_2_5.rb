base {_SET_ file_path: "./resource/bg_sample.png"}
img0 {_SET_ file_path: "./resource/char/B-1.png", x: 250}

_WAIT_ key_push: K_SPACE

_TO_IMAGE_ :test0, width: 1024, height: 600 do 
	_CREATE_ :RuleShaderControl, id: :rule0, vague: 40,
				file_path: "./resource/rule/horizontal_rule.png"
	_SET_ shader: :rule0
end

_END_FRAME_

img0 {_SET_ file_path: "./resource/char/B-2.png"}

test0{
  rule0{
    _MOVE_ 240, counter:[0,255]
  }
}

_END_PAUSE_
test0{_DELETE_}
