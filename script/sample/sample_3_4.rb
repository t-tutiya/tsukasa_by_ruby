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
    screen_modes.each do |screen_mode|
      if screen_mode == [640,480,60]
        menu_button text: "640×480", id: 0
      elsif screen_mode == [800,600,60]
        menu_button text: "800×600", id: 1
      elsif screen_mode == [1024,768,60]
        menu_button text: "1024×768", id: 2
      elsif screen_mode == [1280,720,60]
        menu_button text: "1280×720", id: 3
      end
    end
  end
end

_SET_ [:_ROOT_, :_TEMP_], mode: nil
_WAIT_ [:_ROOT_, :_TEMP_],  not_equal: {mode: nil}

_CHECK_ [:_ROOT_, :_TEMP_],  equal: {mode: 0} do
  _RESIZE_ width: 640, height:480
end
_CHECK_ [:_ROOT_, :_TEMP_],  equal: {mode: 1} do
  _RESIZE_ width: 800, height:600
end
_CHECK_ [:_ROOT_, :_TEMP_],  equal: {mode: 2} do
  _RESIZE_ width: 1024, height:768
end
_CHECK_ [:_ROOT_, :_TEMP_],  equal: {mode: 3} do
  _RESIZE_ width: 1280, height:720
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
