  _INCLUDE_ "./sample/sample4_2.rb"
  _CREATE_ :ImageControl, file_path: "./sozai/button_normal.png",x:0, y:0

  _CREATE_ :LayoutControl, x: 128, y:128, id: :lay0 do
    _CREATE_ :LayoutControl, x: 0, y:0, width:128, height:32, id: :lay1 do
#      TextSelect id: 6, text: "test"
      _CREATE_ :LayoutControl, x: 0, y: 0, width:128, height:32, id: :lay2 do
        _CREATE_ :LayoutControl, x: 0, y: 0, width:128, height:128, float_x: :left do
              _CREATE_ :RenderTargetControl,
          width: 196, height: 32, id: :text_area, bgcolor: [255,255,0]
          _LOOP_ do
            _CHECK_ mouse: [:cursor_over] do
              _EVAL_ "pp'over'"
              text_area{_SET_ bgcolor: [255,0,255]}
            end
            _CHECK_ mouse: [:cursor_out] do
              _EVAL_ "pp'out'"
              text_area{_SET_ bgcolor: [0,0,255]}
            end
          end
        end
        _CREATE_ :LayoutControl, x: 0, y: 0, width:128, height:128 do
              _CREATE_ :RenderTargetControl,
          width: 196, height: 32, id: :text_area, bgcolor: [255,255,0]
          _LOOP_ do
            _CHECK_ mouse: [:cursor_over] do
              _EVAL_ "pp'over'"
              text_area{_SET_ bgcolor: [255,0,255]}
            end
            _CHECK_ mouse: [:cursor_out] do
              _EVAL_ "pp'out'"
              text_area{_SET_ bgcolor: [0,0,255]}
            end
          end
        end
      end
    end
  end

=begin
  _CREATE_ :LayoutControl, x: 128, y:128, width: 512, height:512 do
    _CREATE_ :LayoutControl, x: 128, y:128, width: 512, height:512, id: :sample02 do
      _CREATE_ :ImageControl, file_path: "./sozai/button_over.png",x:128, y:128
    end
  end
=end
=begin
  _CREATE_ :LayoutControl, x: 128, y:128 do
    _CREATE_ :LayoutControl, x: 128, y:128 do
      TextSelect id: 6, text: "test"
    end
  end
=end

