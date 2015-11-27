#! ruby -E utf-8

_CREATE_ :LayoutControl, 
        :x => 150, 
        :y => 150, 
        :width => 256,
        :height => 256,
        :id=>:button1 do
  _CREATE_ :ImageControl, :file_path=>"./sozai/star_button.png", 
        :id=>:normal
  _CREATE_ :ImageControl, :file_path=>"./sozai/button_over.png", 
        :id=>:over, :visible => false
  _CREATE_ :ImageControl, :file_path=>"./sozai/button_key_down.png", 
        :id=>:key_down, :visible => false
  _CREATE_ :ColorkeyControl, :file_path=>"./sozai/star_button.png", :border => 200, id: :colorkey
  _SET_ colorkey: :colorkey
  _DEFINE_ :button_func do
    _CHECK_ mouse: [:cursor_over] do
      pp "over"
      normal  {_SET_ visible: false}
      over    {_SET_ visible: true}
      key_down{_SET_ visible: false}
    end
    _CHECK_ mouse: [:cursor_out] do
      pp "out"
      normal  {_SET_ visible: true}
      over    {_SET_ visible: false}
      key_down{_SET_ visible: false}
    end
    _CHECK_ mouse: [:key_down] do
      pp "key_down"
      normal  {_SET_ visible: false}
      over    {_SET_ visible: false}
      key_down{_SET_ visible: true}
    end
    _CHECK_ mouse: [:key_up] do
      pp "key_up"
      normal  {_SET_ visible: false}
      over    {_SET_ visible: true}
      key_down{_SET_ visible: false}
    end

    #キー押下状態で判定範囲を超えた場合は、以下のイベントをフックして対応する
    _CHECK_ mouse: [:key_down_out] do
      pp "key_down_out"
    end
    _CHECK_ mouse: [:key_up_out] do
      pp "key_up_out"
    end

    #複数個のイベントを登録出来る
    _CHECK_ mouse: [:cursor_over] do
      pp "over 2nd"
    end
    _CHECK_ mouse: [:key_down] do
      pp "key down 2nd"
    end
    _END_FRAME_
    button_func
  end
  button_func
end
