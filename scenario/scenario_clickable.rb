#! ruby -E utf-8

create :ButtonControl, 
        :x_pos => 150, 
        :y_pos => 150, 
        :width => 256,
        :height => 256,
        :id=>:button1 do
  image :file_path=>"./sozai/button_out.png", 
        :id=>:normal
  on_mouse_over do
    pp "over"
  end
  on_mouse_out do
    pp "out"
  end
  on_key_down do
    pp "key_down"
  end
  on_key_up do
    pp "key_up"
  end
end
