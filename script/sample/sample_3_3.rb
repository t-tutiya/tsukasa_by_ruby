_CREATE_ :CharControl, 
  id: :comment_area,
  size: 32, 
  y: 256+196,
  color:[255,255,0], 
  font_name: "ＭＳ ゴシック",
  charactor: " "


_LOOP_ do
  _RUNNING_TIME_ do |time|
    _SEND_ROOT_ do
      _SEND_ :comment_area do
        _SET_ charactor: time.to_s
      end
    end
  end
  _END_FRAME_
end