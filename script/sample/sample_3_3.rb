_DEFINE_ :comment_area do |arg, x:, y:, char:|
  _CREATE_ :CharControl, 
    id: arg,
    size: 32, 
    x: x,
    y: y,
    color:[255,255,0], 
    font_name: "ＭＳ ゴシック",
    charactor: char || ""
end

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

_LOOP_ do
  _SEND_ [:_ROOT_], interrupt: true do
    _SEND_ :comment_area1_b do
      _RUNNING_TIME_ do |time|
        _SET_ charactor: time.to_s
      end
    end
    _SEND_ :comment_area2_b do
      _FPS_ do |fps|
        _SET_ charactor: fps.to_s
      end
    end
    _SEND_ :comment_area3_b do
      _MOUSE_WHEEL_POS_ do |pos|
        _SET_ charactor: pos.to_s
      end
    end
    _PAD_ARROW_ 0 do |x:, y:|
      _SEND_  :comment_area4_b do
        _SET_ charactor: x.to_s
      end
      _SEND_  :comment_area5_b do
        _SET_ charactor: y.to_s
      end
    end
    _GET_ [:mouse_x, :mouse_y] do |arg, options|
      _SEND_ :comment_area6_b do
          _SET_ charactor: options[:mouse_x].to_s + ":" + options[:mouse_y].to_s
      end
    end
  end
  _END_FRAME_
end