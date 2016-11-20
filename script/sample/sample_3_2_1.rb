_CREATE_ :Layout, id: :save_test do
  _CREATE_ :Image, id: :img_A, path: "./resource/char/A-1.png", x:0
  _CREATE_ :Image, id: :img_B, path: "./resource/char/A-1.png", x:256
end

_END_FRAME_

_SEND_ :save_test do
  _QUICK_SAVE_ "./datastore/quick_data.dat"
end
_END_FRAME_

_END_PAUSE_