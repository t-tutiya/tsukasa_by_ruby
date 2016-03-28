_CREATE_ :CharControl, y: 500, charactor:"右クリックで戻る"

_DEFINE_ :menu_button do |x:, y:, id:, text: |
  TextButton text: text, x: x, y: y, id: id,
    width: 196-16, height:32 do |id|
    _SEND_ [:_PARENT_, :_PARENT_, :_PARENT_] do 
      _SEND_ :menu do
        _SET_ child_update: false
      end
      command_window x:32+16, y: 48 + id * 32 + id * 8
    end
  end
end

_DEFINE_ :command_window do |argument, options|
  _CREATE_ :LayoutControl,
    x: options[:x],
    y: options[:y], 
    id: :command  do
    _CREATE_ :RenderTargetControl, id: :menu,
      width: 196,
      height: 32 * 4 + 8 * 6 do
      _CREATE_ :ImageControl, 
              width: 196, height: 32 * 4 + 8 * 6 , color: [255, 0,0,0] do
        _BOX_ x1: 0,      y1: 0,
              x2: 196,    y2: 32 * 4 + 8 * 6, color: [255,255,255]
        _BOX_ x1: 1,      y1: 1, 
              x2: 196 -2, y2: 32 * 4 + 8 * 6 - 2, color: [255,255,255]
      end
      _CREATE_ :LayoutControl, id: :text_box do
        menu_button text: "たたかう", x:8, y:         8     , id:0
        menu_button text: "まほう　", x:8, y:32 +     8 * 2 , id:1
        menu_button text: "ぼうぎょ", x:8, y:32 * 2 + 8 * 3 , id:2
        menu_button text: "にげる",   x:8, y:32 * 3 + 8 * 4 , id:3
      end
    end
    _STACK_LOOP_ do
      #子コントロールがあるなら削除されるまで待機
      _WAIT_ child_not_exist: [:command]
      #システムで右クリックされたら自身を削除
      _CHECK_ system: [:right_key_down] do
        _SEND_ [:_PARENT_, :menu] do
          _SET_ child_update: true
        end
        _SEND_ [:_PARENT_, :menu, :text_box] do
          _SEND_ALL_ interrupt: true do
            text_area{ _SET_ bgcolor: [0,0,0] }
          end
        end
        _DELETE_
      end
      _END_FRAME_
    end
  end
end

command_window x:0, y:0

_LOOP_ do
  _END_FRAME_
end