
_CREATE_ :Layout, id: :layout01 do
_CREATE_ :DrawableLayout, id: :DrawableLayout0, 
  width: 512, height: 128, bgcolor: [128,0,0] do
  _CREATE_ :Image, id: :Image0,
    width: 128, height: 128,
    align_x: :right do
    _FILL_ [255,0,0]
    _TEXT_ text: "右寄せ", color: [255,255,255]
  end
end

_CREATE_ :DrawableLayout, id: :DrawableLayout0, 
  y: 128+64,
  width: 512, height: 128, bgcolor: [0,128,0] do
  _CREATE_ :Image, id: :Image0,
    width: 128, height: 128,
    align_x: :center do
    _FILL_ [0,255,0]
    _TEXT_ text: "中央揃え", color: [255,255,255]
  end
end

_CREATE_ :Image, id: :Image0,
  y: 256 + 128,
  width: 128, height: 128,
  float_x: :left do
  _FILL_ [0,0,128]
  _TEXT_ text: "Ｘ方向連結1", color: [255,255,255]
end
_CREATE_ :Image, id: :Image0,
  y: 256 + 128,
  width: 128, height: 128,
  float_x: :left do
  _FILL_ [0,0,128+32]
  _TEXT_ text: "Ｘ方向連結2", color: [255,255,255]
end
_CREATE_ :Image, id: :Image0,
  y: 256 + 128,
  width: 128, height: 128,
  float_x: :left do
  _FILL_ [0,0,128+64]
  _TEXT_ text: "Ｘ方向連結3", color: [255,255,255]
end
_CREATE_ :Image, id: :Image0,
  y: 256 + 128,
  width: 128, height: 128 do
  _FILL_ [0,0,128+96]
  _TEXT_ text: "Ｘ方向連結4", color: [255,255,255]
end
end

_WAIT_ input:{mouse: :right_push}

_SEND_ :layout01, interrupt: true do
  _DELETE_
end

