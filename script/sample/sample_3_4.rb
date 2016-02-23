_CREATE_ :LayoutControl, id: :top_menu, x:0, y:0 do
  _SCREEN_MODES_ do |screen_modes|
    screen_modes.each do |screen_mode|
      if screen_mode == [640,480,60]
        TextSelect text: "640×480", path: 0
      elsif screen_mode == [800,600,60]
        TextSelect text: "800×600", path: 1
      elsif screen_mode == [1024,768,60]
        TextSelect text: "1024×768", path: 2
      elsif screen_mode == [1280,720,60]
        TextSelect text: "1280×720", path: 3
      end
    end
  end
end

_SET_ :_TEMP_, file_path: nil
_WAIT_ :_TEMP_,  not_equal: {file_path: nil}

_CHECK_ :_TEMP_,  equal: {file_path: 0} do
  _RESIZE_ width: 640, height:480
end
_CHECK_ :_TEMP_,  equal: {file_path: 1} do
  _RESIZE_ width: 800, height:600
end
_CHECK_ :_TEMP_,  equal: {file_path: 2} do
  _RESIZE_ width: 1024, height:768
end
_CHECK_ :_TEMP_,  equal: {file_path: 3} do
  _RESIZE_ width: 1280, height:720
end

_SEND_ :top_menu do
  _DELETE_
end

img0{_SET_ file_path: "./resource/button_normal.png"}
img1{_SET_ file_path: "./resource/char/A-1.png"}

_FULL_SCREEN_ true

end_pause

_FULL_SCREEN_ false

_RESIZE_ width: 1024, height:600
