#! ruby -E utf-8

#ボタンコントロール
_CREATE_ :RenderTargetControl, 
        :x => 150, 
        :y => 150, 
        :width => 256,
        :height => 256,
        :id=>:button1,
        :collision_shape=>[128,128,128] do
  _CREATE_ :ImageControl, :entity=>Image.new(256,256).circle_fill(128,128,128,C_BLUE).draw_font(80, 120, "NORMAL", Font.default),
        :id=>:normal
  _CREATE_ :ImageControl, :entity=>Image.new(256,256).circle_fill(128,128,128,C_YELLOW).draw_font(80, 120, "OVER", Font.default, C_BLACK),
        :id=>:over, :visible => false
  _CREATE_ :ImageControl, :entity=>Image.new(256,256).circle_fill(128,128,128,C_GREEN).draw_font(80, 120, "DOWN", Font.default),
        :id=>:key_down, :visible => false
  on_mouse_over do
    normal  {_SET_ visible: false}
    over    {_SET_ visible: true}
    key_down{_SET_ visible: false}
  end
  on_mouse_out do
    normal  {_SET_ visible: true}
    over    {_SET_ visible: false}
    key_down{_SET_ visible: false}
  end
  on_key_down do
    normal  {_SET_ visible: false}
    over    {_SET_ visible: false}
    key_down{_SET_ visible: true}
  end
  on_key_up do
    normal  {_SET_ visible: false}
    over    {_SET_ visible: true}
    key_down{_SET_ visible: false}
  end
end

_CREATE_ :RenderTargetControl, 
        :x => 450, 
        :y => 150, 
        :width => 256,
        :height => 256,
        :id=>:button2,
        :collision=>[128,0,0,255,255,255] do
  _CREATE_ :ImageControl, :entity=>Image.new(256,256).triangle_fill(128,0,0,255,255,255,C_BLUE).draw_font(80, 120, "NORMAL", Font.default),
        :id=>:normal
  _CREATE_ :ImageControl, :entity=>Image.new(256,256).triangle_fill(128,0,0,255,255,255,C_YELLOW).draw_font(80, 120, "OVER", Font.default, C_BLACK),
        :id=>:over, :visible => false
  _CREATE_ :ImageControl, :entity=>Image.new(256,256).triangle_fill(128,0,0,255,255,255,C_GREEN).draw_font(80, 120, "DOWN", Font.default),
        :id=>:key_down, :visible => false
  on_mouse_over do
    normal  {_SET_ visible: false}
    over    {_SET_ visible: true}
    key_down{_SET_ visible: false}
  end
  on_mouse_out do
    normal  {_SET_ visible: true}
    over    {_SET_ visible: false}
    key_down{_SET_ visible: false}
  end
  on_key_down do
    normal  {_SET_ visible: false}
    over    {_SET_ visible: false}
    key_down{_SET_ visible: true}
  end
  on_key_up do
    normal  {_SET_ visible: false}
    over    {_SET_ visible: true}
    key_down{_SET_ visible: false}
  end
end
