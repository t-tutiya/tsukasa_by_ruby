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
  image :file_path=>"./sozai/button_key_up.png", 
        :id=>:key_up, :visible => false
  image :file_path=>"./sozai/button_out.png", 
        :id=>:out, :visible => false
  on_mouse_over do
    pp "over"
    set :normal, visible: false
    set :over,   visible: true
    set :key_down, visible: false
  end
  on_mouse_out do
    pp "out"
    set :over,   visible: false
    set :normal, visible: true
    set :key_down, visible: false
  end
  on_key_down do
    #TODO：現状の実装では、キーを押下したままout->overした場合、on_key_downイベントは再起動しない。適切な挙動を考える。
    pp "key_down"
    set :over,   visible: false
    set :normal, visible: false
    set :key_down, visible: true
  end
  on_key_up do
    pp "key_up"
    set :key_down, visible: false
    set :normal, visible: false
    set :over,   visible: true
  end
end
