#テキストボタン定義
_DEFINE_ :TextSelect2 do |options|
  _CREATE_ :LayoutControl,
    x: options[:x], y: options[:y], width: 350, height: 32, id: options[:id] do
    _CREATE_ :RenderTargetControl,
      width: 350, height: 32, id: :text_area, bgcolor: [255,255,255] do
      _CREATE_ :CharControl,
        size: 32, 
        font_name: "ＭＳＰ ゴシック",
        charactor: options[:text]
    end
    on_mouse_over do
      text_area{
      _SET_ bgcolor: [0,255,255]
      last{
        _MOVE_ 30, x:[350,0], option:{easing: :out_cubic}
        #_SET_ charactor:  options[:text] + "を実行します"
      }
      }
    end
    on_mouse_out do
      text_area{
      _SET_ bgcolor: [255,255,255]
      last{
        _MOVE_ 30, x:[350,0], option:{easing: :out_cubic}
        _SET_ charactor:  options[:text]
      }
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
    on_right_key_down do
      _EVAL_ "pp 'main:on_right_key_down'"
      _WAKE_ :menu_scene
      _SEND_ROOT_ :menu_scene , interrupt: true do
        start_menu
      end
      _SLEEP_
    end
end
#メニューシーン
_CREATE_ :LayoutControl, width: 800, height: 600, 
        id: :menu_scene do
  TextSelect2 id: :select1, x:800, y:  0, text: "SAVE"
  TextSelect2 id: :select2, x:800, y: 64, text: "LOAD"
  TextSelect2 id: :select3, x:800, y:128, text: "STATUS"
  TextSelect2 id: :select4, x:800, y:192, text: "CONFIG"
  TextSelect2 id: :select5, x:800, y:256, text: "???"

  _DEFINE_ :start_menu do
    select1{ _MOVE_ 10, x: 600, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select2{ _MOVE_ 10, x: 600, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select3{ _MOVE_ 10, x: 600, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select4{ _MOVE_ 10, x: 600, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select5{ _MOVE_ 10, x: 600, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select6{ _MOVE_ 10, x: 600, option:{easing: :out_cubic}}
    _WAIT_ count:7
  end

  _DEFINE_ :end_menu do
    select1{ _MOVE_ 5, x: 800, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select2{ _MOVE_ 5, x: 800, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select3{ _MOVE_ 5, x: 800, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select4{ _MOVE_ 5, x: 800, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select5{ _MOVE_ 5, x: 800, option:{easing: :out_cubic}}
    _WAIT_ count:3
    select6{ _MOVE_ 5, x: 800, option:{easing: :out_cubic}}
    _WAIT_ count:5
    _WAKE_ :main_scene
    _SLEEP_
  end

  _SLEEP_

  on_right_key_down do
    _SET_ :_TEMP_ , skip: true
    _EVAL_ "pp 'menu:on_right_key_down'"
    end_menu
  end
end
