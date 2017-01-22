_DEFINE_ :menu_button do |id:, text: |
  _TEXT_BUTTON_ text: text, 
    id: id,
    width: 228, 
    height:32,
    char_color: [255,255,0], #文字色
    out_color: [0,255,255],
    float_y: :bottom do
    #キーがクリックされた
    _DEFINE_ :on_key_push do
      _SET_ [:_ROOT_, :_TEMP_], mode: id
    end
  end
end

_CREATE_ :Layout, id: :top_menu, x:0, y:0 do
  _GET_ :screen_modes, control:[:_ROOT_]  do |screen_modes:|
    screen_modes.each_with_index do |screen_mode, id|
      if screen_mode[2] == 60
        menu_button text: "#{screen_mode[0]}×#{screen_mode[1]}", id: id
      end
    end
  end
end

_SET_ [:_ROOT_, :_TEMP_], mode: nil
_WAIT_ [:_ROOT_, :_TEMP_],  not_equal: {mode: nil}

_GET_ :screen_modes, control:[:_ROOT_]  do |screen_modes:|
  screen_modes.each_with_index do |screen_mode, id|
    if screen_mode[2] == 60
      _CHECK_ [:_ROOT_, :_TEMP_],  equal: {mode: id} do
        _RESIZE_ width: screen_mode[0], height: screen_mode[1]
      end
    end
  end
end

_SEND_ :top_menu do
  _DELETE_
end

_SEND_(:img0){_SET_ path: "./resource/button_normal.png"}
_SEND_(:img1){_SET_ path: "./resource/char/A-1.png"}

_SET_ full_screen: true

_END_PAUSE_

_SET_ full_screen: false

_RESIZE_ width: 1024, height:600
