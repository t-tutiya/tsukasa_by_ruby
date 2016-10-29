_SET_ :_TEMP_, click: nil

_IMAGE_BUTTON_ :button1, x: 50, y: 150 do
   _DEFINE_ :on_key_push_user do
    _SET_ :_TEMP_, click: :left
   end
end
_IMAGE_BUTTON_ :button2, x: 450, y: 150 do
   _DEFINE_ :on_key_push_user do
		_SET_ :_TEMP_, click: :right
   end
end

_WAIT_ :_TEMP_, not_equal: {click: nil}

_CHECK_ :_TEMP_, equal:{click: :left} do
	_INCLUDE_ "./script/sample/sample_1_15a.rb"
end

_CHECK_ :_TEMP_,equal:{click: :right} do
	_INCLUDE_ "./script/sample/sample_1_15b.rb"
end

_SEND_ :button1, interrupt: true do
  _DELETE_
end
_SEND_ :button2, interrupt: true do
  _DELETE_
end
_SEND_ :text0 do
  _FLUSH_
end
