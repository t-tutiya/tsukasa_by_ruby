_DEFINE_ :comment_area do |_ARGUMENT_:, x:, y:, char:|
  _CREATE_ :Char, 
    id: _ARGUMENT_,
    size: 32, 
    x: x,
    y: y,
    color:[255,255,0], 
    font_name: "ＭＳ ゴシック",
    char: char || ""
end

_CREATE_ :Layout, id: :layout01 do
comment_area :comment_area1_a, x:0, y:256+192, char: "running_time"
comment_area :comment_area1_b, x:256, y:256+192,  char: ""
comment_area :comment_area2_a, x:0, y:256+160,  char: "fps"
comment_area :comment_area2_b, x:256, y:256+160,  char: ""
comment_area :comment_area3_a, x:0, y:256+32,  char: "mouse_wheel"
comment_area :comment_area3_b, x:256, y:256+32,  char: ""
comment_area :comment_area4_a, x:0, y:256+64,  char: "x_pad"
comment_area :comment_area4_b, x:256, y:256+64,  char: ""
comment_area :comment_area5_a, x:0, y:256+96,  char: "y_pad"
comment_area :comment_area5_b, x:256, y:256+96,  char: ""
comment_area :comment_area6_a, x:0, y:256,  char: "mouse"
comment_area :comment_area6_b, x:256, y:256,  char: ""
comment_area :comment_area6_b2, x:256, y:256-32,  char: ""
comment_area :comment_area6_a, x:0, y:256-32,  char: "mouse offset"
end

_LOOP_ do
  _SEND_ [:_ROOT_], interrupt: true do
    _SEND_ :layout01 do
    _SEND_ :comment_area1_b do
      _RUNNING_TIME_ do |time:|
        _SET_ char: time.to_s
      end
    end
    _SEND_ :comment_area2_b do
      _FPS_ do |fps:|
        _SET_ char: fps.to_s
      end
    end
    _SEND_ :comment_area3_b do
      _MOUSE_WHEEL_POS_ do |pos:|
        _SET_ char: pos.to_s
      end
    end
    _PAD_ARROW_ 0 do |x:, y:|
      _SEND_  :comment_area4_b do
        _SET_ char: x.to_s
      end
      _SEND_  :comment_area5_b do
        _SET_ char: y.to_s
      end
    end
    _GET_ [:_MOUSE_POS_X_, :_MOUSE_POS_Y_],  control: [:_ROOT_, :_TEMP_] do |_MOUSE_POS_X_:, _MOUSE_POS_Y_:|
      _SEND_ :comment_area6_b do
          _SET_ char: _MOUSE_POS_X_.to_s + ":" + _MOUSE_POS_Y_.to_s
      end
    end
    _GET_ [:_MOUSE_OFFSET_X_, :_MOUSE_OFFSET_Y_],  control: [:_ROOT_, :_TEMP_] do |_MOUSE_OFFSET_X_:, _MOUSE_OFFSET_Y_:|
      _SEND_ :comment_area6_b2 do
          _SET_ char: _MOUSE_OFFSET_X_.to_s + ":" + _MOUSE_OFFSET_Y_.to_s
      end
    end
  end
  end
  _CHECK_INPUT_ mouse: :right_push do
    _SEND_ :layout01, interrupt: true do
      _DELETE_
    end
    _BREAK_
  end
  _END_FRAME_
end

