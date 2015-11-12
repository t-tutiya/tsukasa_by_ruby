#! ruby -E utf-8

_CREATE_ :RenderTargetControl, 
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
  on_mouse_over do
    pp "over"
    normal  {_SET_ visible: false}
    over    {_SET_ visible: true}
    key_down{_SET_ visible: false}
  end
  on_mouse_out do
    pp "out"
    normal  {_SET_ visible: true}
    over    {_SET_ visible: false}
    key_down{_SET_ visible: false}
  end
  on_key_down do
    pp "key_down"
    normal  {_SET_ visible: false}
    over    {_SET_ visible: false}
    key_down{_SET_ visible: true}
  end
  on_key_up do
    pp "key_up"
    normal  {_SET_ visible: false}
    over    {_SET_ visible: true}
    key_down{_SET_ visible: false}
  end

  #キー押下状態で判定範囲を超えた場合は、以下のイベントをフックして対応する
  on_key_down_out do
    pp "key_down_out"
  end
  on_key_up_out do
    pp "key_up_out"
  end

  #複数個のイベントを登録出来る
  on_mouse_over do
    pp "over 2nd"
  end
  on_key_down do
    pp "key down 2nd"
  end
end
