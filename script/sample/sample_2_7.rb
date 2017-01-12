_CREATE_ :Image, id: :horror_img, x: 64, y: 64, width: 1024, height: 200 do
  _CREATE_ :HorrorShader, id: :horror, width: 640, height: 200
  _GET_ :shader, control: [:horror] do |shader:|
    _SET_ shader: shader
  end
  _TEXT_  text: "むかしむかしあるところに、おじいさんとおばあさんがおったそうな。", size: 32, color: [255,0,0]

  _DEFINE_ :status do
    _GET_ [:duration, 
            :check_mode, 
            :mode, 
            :count, 
            :wavePhaseU, 
            :wavePhaseV, 
            :waveAmpU, 
            :waveAmpV, 
            :waveLength, 
            :wave_speed_u, 
            :wave_speed_v, 
            :wave_amp_u, 
            :wave_amp_v, 
            :wave_length,
            :texelSize], 
            control: [:_ROOT_, :horror_img, :horror] do | 
            duration:, 
            check_mode:, 
            mode:, 
            count:, 
            wavePhaseU:, 
            wavePhaseV:, 
            waveAmpU:, 
            waveAmpV:, 
            waveLength:, 
            wave_speed_u:, 
            wave_speed_v:, 
            wave_amp_u:, 
            wave_amp_v:, 
            wave_length:,
            texelSize:|

      if check_mode
        count = count + (mode == 0 ? 1 : - 1)
      end
      
      _SET_ [:_ROOT_, :horror_img, :horror], 
        count: count,
        wavePhaseU: ((wavePhaseU + wave_speed_u) % 360), 
        wavePhaseV: ((wavePhaseV + wave_speed_v) % 360), 
        waveAmpU: (wave_amp_u * count / duration), 
        waveAmpV: (wave_amp_v * count / duration), 
        waveLength: (360.0 / (wave_length * texelSize)) 
    end
    _RETURN_ do
      _END_FRAME_
      status
    end
  end

  status

end

_LOOP_ do
  _END_FRAME_
end