#テキストボタン定義
_DEFINE_ :TextSelect2 do |options|
  _CREATE_ :RenderTargetControl, 
  x: options[:x], y: options[:y], width: 350, height: 32,
  bgcolor: [255,255,255] do
    _CREATE_ :CharControl,
    size: 32, 
    font_name: "ＭＳＰ ゴシック",
    charactor: options[:text] do
    end
    on_mouse_over do
      
      _SET_ bgcolor: [0,255,255]
      last{
        _MOVE_ 30, x:[350,0], option:{easing: :out_cubic}
        _SET_ charactor:  options[:text] + "を実行します"
      }
    end
    on_mouse_out do
      _SET_ bgcolor: [255,255,255]
      last{
        _MOVE_ 30, x:[350,0], option:{easing: :out_cubic}
        _SET_ charactor:  options[:text]
      }
    end
    on_key_down do
      _SET_ :_TEMP_ , select: "./sample/" + options[:text] + ".tks"
    end
    _YIELD_
  end
end

_CREATE_ :LayoutControl, width: 800, height: 600,
        id: :main_scene do
  #_SET_ sleep: true
  #_WAIT_ sleep: false
  on_right_key_down do
    _SEND_ROOT_ :menu_scene , interrupt: true do
      _SET_ visible: true, sleep: false
    end
  end
end

#メニューシーン
_CREATE_ :LayoutControl, width: 800, height: 600, 
        id: :menu_scene do
  TextSelect2 id: :select1, x:0, y:  0, text: "sample_1_1"
  TextSelect2 id: :select1, x:0, y: 64, text: "sample_1_2"
  _SET_ sleep: true, visible: false
=begin
  on_right_key_down do
    _SEND_ROOT_ :main_scene, interrupt: true do
      _SET_ sleep: false
    end
    _SET_ sleep: true
  end
=end
end

=begin
_CREATE_ :LayoutControl, width: 800, height: 600,
        id: :main_scene do
  _SET_ sleep: true
  _WAIT_ sleep: false
  on_right_key_down do
    _SEND_ROOT_ :menu_scene do
      raise
    end
  end
end

#メニューシーン
_CREATE_ :LayoutControl, width: 800, height: 600, 
        id: :menu_scene do
  on_right_key_down do
    TextSelect2 id: :select1, x:0, y:  0, text: "sample_1_1"
    TextSelect2 id: :select1, x:0, y: 64, text: "sample_1_2"
    _SEND_ROOT_ :main_scene, interrupt: true do
      _SET_ sleep: false
    end
    _SET_ sleep: true
  end
end
=end
