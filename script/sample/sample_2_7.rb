_CREATE_ :Image, x: 64, y: 64, width: 1024, height: 200 do
  _CREATE_ :HorrorShader, id: :horror
  _GET_ :shader, control: [:horror] do |shader:|
    _SET_ shader: shader
  end
  _TEXT_  text: "むかしむかしあるところに、おじいさんとおばあさんがおったそうな。", size: 32, color: [255,0,0]

end

_LOOP_ do
  _END_FRAME_
end