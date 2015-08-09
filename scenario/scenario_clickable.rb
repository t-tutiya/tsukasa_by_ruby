#! ruby -E utf-8

create :ButtonControl, 
        :x_pos => 150, 
        :y_pos => 150, 
        :width => 256,
        :height => 256,
        :id=>:button1 do
  image :file_path=>"./sozai/button_normal.png", 
        :id=>:normal
  image :file_path=>"./sozai/button_over.png", 
        :id=>:over, :visible => false
  image :file_path=>"./sozai/button_key_down.png", 
        :id=>:key_down, :visible => false
  on_mouse_over do
    pp "over"
    set target: :normal, visible: false
    set target: :over,   visible: true
    set target: :key_down, visible: false
  end
  on_mouse_out do
    pp "out"
    set target: :over,   visible: false
    set target: :normal, visible: true
    set target: :key_down, visible: false
  end
  on_key_down do
    pp "key_down"
    set target: :over,   visible: false
    set target: :normal, visible: false
    set target: :key_down, visible: true
  end
  on_key_up do
    pp "key_up"
    set target: :key_down, visible: false
    set target: :normal, visible: false
    set target: :over,   visible: true
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
