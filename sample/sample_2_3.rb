#テキストボタン定義
_DEFINE_ :TextSelect do |options|
  _CREATE_ :LayoutControl,
    x: options[:x], y: options[:y], width: 350, height: 32, id: options[:id] do
    _CREATE_ :RenderTargetControl,
      width: 350, height: 32, id: :text_area, bgcolor: [255,255,255] do
      _CREATE_ :CharControl, size: 32, font_name: "ＭＳＰ ゴシック", charactor: options[:text]
    end
    on_mouse_over do
      text_area{
        _SET_ bgcolor: [0,255,255]
        last{
          _MOVE_ 30, x:[350,0], option:{easing: :out_cubic}
          _SET_ color:  [255,0,0], edge_color: [255,255,255]
        }
      }
    end
    on_mouse_out do
      text_area{
        _SET_ bgcolor: [255,255,255]
        last{
          _MOVE_ 30, x:[350,0], option:{easing: :out_cubic}
          _SET_ color:  [255,255,255], edge_color: [0,0,0]
        }
      }
    end
    on_key_down do
      _SET_ :_TEMP_ , select: "./sample/" + options[:text] + ".tks"
    end
    _YIELD_
  end
end

_CREATE_ :LayoutControl, width: 800, height: 600, id: :main_scene do
  on_right_key_down do
    _SEND_ROOT_ do
      def_menu_scene
    end
    _SLEEP_
  end
end

_DEFINE_ :def_menu_scene do
  #メニューシーン
  _CREATE_ :LayoutControl, width: 800, height: 600, id: :menu_scene do
    TextSelect id: :select1, x:800, y: 64, text: "SAVE"
    TextSelect id: :select2, x:800, y:128, text: "LOAD"
    TextSelect id: :select3, x:800, y:192, text: "STATUS"
    TextSelect id: :select4, x:800, y:256, text: "CONFIG"
    TextSelect id: :select5, x:800, y:256+64, text: "???"

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

=begin
    _LOOP_ false do
      on_right_key_down do
        _BREAK_
      end
    end

    end_menu
=end

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
      _DELETE_
    end

    on_right_key_down do
      _SEND_ do
        end_menu
      end
    end
  end
end