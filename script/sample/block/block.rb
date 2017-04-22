#! ruby -E utf-8
# ==================================================================
#
# 司エンジン: ブロック崩しデモ
# version 1.0.0
#
# author       : Taku Aoi (https://github.com/aoitaku)
# license      : zlib/libpng (https://opensource.org/licenses/Zlib)
# published at : 2016-11-13
#
# ==================================================================
#
# Copyright (c) 2016 Taku Aoi
#
# This software is provided 'as-is', without any express or
# implied warranty. In no event will the authors be held
# liable for any damages arising from the use of this software.
#
# Permission is granted to anyone to use this software for
# any purpose, including commercial applications, and to alter
# it and redistribute it freely, subject to the following
# restrictions:
#
# 1. The origin of this software must not be misrepresented;
#    you must not claim that you wrote the original software.
#    If you use this software in a product, an acknowledgment
#    in the product documentation would be appreciated but is
#    not required.
#
# 2. Altered source versions must be plainly marked as such,
#    and must not be misrepresented as being the original software.
#
# 3. This notice may not be removed or altered from any source
#    distribution.
#
# ==================================================================

STAGE_WIDTH = 600
STAGE_HEIGHT = DXRuby::Window.height
BAR_INIT_X = 30
BAR_INIT_Y = STAGE_HEIGHT - 30
BAR_INIT_WIDTH = 100
BAR_INIT_HEIGHT = 10
BALL_INIT_X = BAR_INIT_X + BAR_INIT_WIDTH / 2 - 5
BALL_INIT_Y = BAR_INIT_Y - BAR_INIT_HEIGHT
BRICK_ROWS = 12
BRICK_COLS = 12
BRICK_WIDTH = 46
BRICK_HEIGHT = 10
FRAME_X = STAGE_WIDTH
FRAME_Y = 0
FRAME_WIDTH = DXRuby::Window.width - STAGE_WIDTH
FRAME_HEIGHT = DXRuby::Window.height
BRICKS = BRICK_COLS.times.to_a.product(BRICK_ROWS.times.to_a)

_CREATE_ :DrawableLayout, id: :frame, x: FRAME_X, y: FRAME_Y, width: FRAME_WIDTH, height: FRAME_HEIGHT, alpha: 0 do
  _CREATE_ :Image, x: 8, y: 8, width: (FRAME_WIDTH - 24) / 2, height: 24 do
    _TEXT_ "REST", x: 0, y: 0, color: [255, 255, 255]
  end
  _CREATE_ :Image, id: :rest, x: (FRAME_WIDTH - 24) / 2 + 8, y: 8, width: (FRAME_WIDTH - 24) / 2, height: 24 do
    _TEXT_ "3", x: 0, y: 0, color: [255, 255, 255]
    _DEFINE_ :_UPDATE_ do
      _GET_ :ball_rest, control: [:_ROOT_, :stage] do |ball_rest:|
        _CLEAR_
        _TEXT_ ball_rest.to_s, x: 0, y: 0, color: [255, 255, 255]
      end
    end
  end

  _MOVE_ [30, easing: :out_sine], alpha: [0, 255]
end

_CREATE_ :DrawableLayout, id: :stage, width: STAGE_WIDTH, height: STAGE_HEIGHT, alpha: 0 do
  _DEFINE_PROPERTY_ bricks: BRICK_ROWS * BRICK_COLS, ball_alive: true, ball_rest: 3

  _CREATE_ :Image, id: :message_ready, width: 600, height: 600, x: 0, y: 0, z: 100 do
    text = 'PRESS SPACE KEY TO PLAY'
    text_width = DXRuby::Font.default.get_width(text)
    _TEXT_ text, x: (600 - text_width) / 2, y: (600 - 24) / 2, color: [255 ,255 ,255]
  end

  _CREATE_ :Image, id: :message_success, width: 300, height: 300, x: 150, y: 150 do
    _SET_ visible: false
    text = 'LEVEL SUCCESS!'
    text_width = DXRuby::Font.default.get_width(text)
    _TEXT_ text, x: (300 - text_width) / 2, y: (300 - 24) / 2, color: [255 ,255 ,255]
  end

  _CREATE_ :Image, id: :message_miss, width: 300, height: 300, x: 150, y: 150 do
    _SET_ visible: false
      text = 'MISS.'
      text_width = DXRuby::Font.default.get_width(text)
      _TEXT_ text, x: (300 - text_width) / 2, y: (300 - 24) / 2, color: [255 ,255 ,255]
  end

  _CREATE_ :Image, id: :message_failure, width: 300, height: 300, x: 150, y: 150 do
    _SET_ visible: false
      text = 'LEVEL FAILURE...'
      text_width = DXRuby::Font.default.get_width(text)
      _TEXT_ text, x: (300 - text_width) / 2, y: (300 - 24) / 2, color: [255 ,255 ,255]
  end

  _CREATE_ :Image, id: :message_play_again, width: 300, height: 300, x: 150, y: 150 do
    _SET_ visible: false
    text = 'PLAY AGAIN?'
    text_width = DXRuby::Font.default.get_width(text)
    _TEXT_ text, x: (300 - text_width) / 2, y: (300 - 24) / 2 - 32, color: [255 ,255 ,255]
  end
  _CREATE_ :Image, id: :select_play, width: 300, height: 300, x: 150, y: 150 do
    _SET_ visible: false
    text = 'PLAY'
    text_width = DXRuby::Font.default.get_width(text)
    _TEXT_ text, x: (300 / 2 - text_width) / 2, y: (300 - 24) / 2 + 32, color: [255 ,255 ,255]
  end
  _CREATE_ :Image, id: :select_exit, width: 300, height: 300, x: 150, y: 150 do
    _SET_ visible: false
    text = 'EXIT'
    text_width = DXRuby::Font.default.get_width(text)
    _TEXT_ text, x: 300 / 2 + (300 / 2 - text_width) / 2, y: (300 - 24) / 2 + 32, color: [255 ,255 ,255]
  end

  _CREATE_ :Image, id: :wall_left, width: 10, height: 600, color: [128, 128, 128], x: 0, y: 0 do
  end

  _CREATE_ :Image, id: :wall_right, width: 10, height: 600, color: [128, 128, 128], x: 590, y: 0 do
  end

  _CREATE_ :Image, id: :ceil, width: 580, height: 10, color: [128, 128, 128], x: 10, y: 0 do
  end

  _DEFINE_ :_CREATE_BRICKS_ do
    _CREATE_ :DrawableLayout, id: :bricks, width: STAGE_WIDTH, height: STAGE_HEIGHT do
      BRICKS.each do |x, y|
        _CREATE_ :Image, width: BRICK_WIDTH, height: BRICK_HEIGHT, color: [255, 255, 255], x: 13 + 48 * x, y: 37 + 12 * y do
          _DEFINE_ :state_normal do
            local_vars = {}
            _GET_ [:x, :vx, :y, :vy], control: [:_ROOT_, :stage, :ball] do |x:, vx:, y:, vy:|
              local_vars[:vx] = vx
              local_vars[:vy] = vy
              local_vars[:center_x] = x + vx + 10 / 2
              local_vars[:center_y] = y + vy + 10 / 2
              local_vars[:ball_r] = 10 / 2
            end
            _GET_ [:x, :y] do |x:, y:|
              vx = local_vars[:vx]
              vy = local_vars[:vy]
              center_x = local_vars[:center_x]
              center_y = local_vars[:center_y]
              ball_r = local_vars[:ball_r]
              left = x - ball_r
              right = x + BRICK_WIDTH + ball_r
              top = y - ball_r
              bottom = y + 10 + ball_r
              if left < center_x && center_x < right && top < center_y && center_y < bottom
                _SEND_ [:_ROOT_, :stage, :ball], interrupt: true do
                  _CHECK_ equal: { boost: false } do
                    if center_x < left + ball_r * 2 || right - ball_r * 2 < center_x
                      _SET_ vx: vx * -1
                    end
                    if center_y < top + ball_r * 2 || bottom - ball_r * 2 < center_y
                      _SET_ vy: vy * -1
                    end
                  end
                end
                _RETURN_ do
                  local_vars.clear
                  state_break
                end
              end
            end
            _HALT_
            _RETURN_ do
              state_normal
            end
          end

          _DEFINE_ :state_break do
            _GET_ [:x, :y] do |x:, y:|
              _SEND_ [:_ROOT_, :stage], interrupt: true do
                particles = (BRICK_WIDTH / 4).times.to_a.product((BRICK_HEIGHT / 2).times.to_a)
                particles.sample(particles.size / 8).each do |col, row|
                  particle_width = (BRICK_WIDTH * 1.0) / (BRICK_WIDTH / 4)
                  particle_height = (BRICK_HEIGHT * 1.0) / (BRICK_HEIGHT / 2)
                  center_x = x + BRICK_WIDTH / 2.0
                  center_y = y + BRICK_HEIGHT / 2.0
                  particle_x = x + particle_width * col
                  particle_y = y + particle_height * row
                  direction = Math.atan2((particle_x - center_x), (particle_y - center_y))
                  _CREATE_ :Image, x: particle_x, y: particle_y, width: 1, height: 1, color: [[255, 192, 0], [255, 128, 0], [128, 255, 0, 0]].sample do
                    _DEFINE_PROPERTY_ velocity: 0, direction: direction
                    _GET_ :angle do |angle:|
                      _MOVE_ [12], scale_x: [12, 1], scale_y: [12, 1], velocity: [4, 1] do
                        _GET_ [:x, :y, :velocity, :angle] do |x:, y:, velocity:, angle:|
                          vx = Math.sin(direction) * velocity
                          vy = Math.cos(direction) * velocity * -1
                          _SET_ x: x + vx
                          _SET_ y: y + vy
                        end
                      end
                    end
                    _DELETE_
                  end
                end
              end
              _SEND_ [:_ROOT_, :stage], interrupt: true do
                _GET_ :bricks do |bricks:|
                  _SET_ bricks: bricks - 1
                end
              end
              _DELETE_
            end
          end

          state_normal
        end
      end
    end
  end

  _CREATE_ :Image, id: :bar, width: BAR_INIT_WIDTH, height: BAR_INIT_HEIGHT, color: [255, 255, 255] do
    _DEFINE_PROPERTY_ vx: 0, wait: true

    local_vars = {}

    local_vars[:wall_width] = 10

      wall_width = local_vars[:wall_width]
      _DEFINE_ :state_move do
        _GET_ [:x, :y], control: [:_ROOT_, :_INPUT_] do |x:, y:|
          pad_x = x
          _GET_ [:x, :vx] do |x:, vx:|
            vx += pad_x * 2
            case
            when x + vx <= wall_width
              x, vx = wall_width, 0
            when STAGE_WIDTH - wall_width - BAR_INIT_WIDTH <= x + vx
              x, vx = STAGE_WIDTH - wall_width - BAR_INIT_WIDTH, 0
            end
            _SET_ x: x + vx
            _SET_ vx: vx * 0.9
          end
        end
      end

      _DEFINE_ :state_normal do
        _CHECK_ equal: { wait: true } do
          _HALT_
          _RETURN_ do
            state_wait
          end
        end
        state_move
        _HALT_
        _RETURN_ do
          state_normal
        end
      end

      _DEFINE_ :state_wait do
        _CHECK_ equal: { wait: false } do
          _HALT_
          _RETURN_ do
            state_normal
          end
        end
        _HALT_
        _RETURN_ do
          state_wait
        end
      end

      state_wait
  end

  _CREATE_ :Image, id: :ball, width: 10, height: 10, color: [0, 0, 0, 0] do
    _DEFINE_PROPERTY_ vx: 0, vy: 0, spin: 0, boost: false, ready: true, wait: true
    _CIRCLE_ fill: true, x: 5, y: 5, r: 5, color: [255, 255, 255]

    _DEFINE_ :_RESET_ do
      _SET_ vx: 0
      _SET_ vy: 0
      _SET_ spin: 0
      _SET_ boost: false
      _SET_ visible: false
    end

    local_vars = {}
    local_vars[:wall_left_x] = 10

    local_vars[:wall_rigth_x] = 590
    local_vars[:ceil_bottom_y] = 10

      wall_left_x = local_vars[:wall_left_x]
      wall_rigth_x = local_vars[:wall_rigth_x]
      ceil_bottom_y = local_vars[:ceil_bottom_y]
      _DEFINE_ :state_move do
        _GET_ [:x, :y, :vx, :vy] do |x:, y:, vx:, vy:|
          case
          when x + vx <= wall_left_x
           _SET_ vx: vx * -1
            x, vx = wall_left_x, 0
          when wall_rigth_x - 10 <= x + vx
            _SET_ vx: vx * -1
            x, vx = wall_rigth_x - 10, 0
          end
          case
          when y + vy <= ceil_bottom_y
            _SET_ vy: vy * -1
            y, vy = ceil_bottom_y, 0
          when STAGE_HEIGHT <= y + vy
            y, vy = STAGE_HEIGHT, 0
            _SEND_ [:_PARENT_], interrupt: true do
              _SET_ ball_alive: false
            end
            _RESET_
            _RETURN_ do
              _SET_ ready: false
              state_miss
            end
          end
          ball_vx = vx
          center_x, center_y = x + vx + 5, y + vy + 5
          _GET_ [:x, :y, :vx], control: [:_PARENT_, :bar] do |x:, y:, vx:|
            left = x - 5
            right = x + BAR_INIT_WIDTH + 5
            top = y - 5
            bottom = y + BAR_INIT_HEIGHT + 5
            if left < center_x && center_x < right && top < center_y && center_y < bottom
              _SET_ spin: vx / -2
              _SET_ vy: vy * -1
              if left + BAR_INIT_WIDTH / 2 - 10 < center_x && center_x < right - BAR_INIT_WIDTH / 2 + 10
                _SET_ boost: true
              else
                _SET_ boost: false
              end
            end
          end
          _GET_ :spin do |spin:|
            _SET_ x: x + (vx + spin)
            _SET_ y: y + vy
            _SET_ spin: spin * 0.98
            if (spin * 0.98).abs < 1
              _SET_ spin: 0
            end
          end
        end
      end

    _DEFINE_ :state_miss do
      _CHECK_ equal: { ready: true } do
        _HALT_
        _RETURN_ do
          state_idle
        end
      end
      _HALT_
      _RETURN_ do
        state_miss
      end
    end

    _DEFINE_ :state_idle do
      _CHECK_ equal: { wait: true } do
        _HALT_
        _RETURN_ do
          state_wait
        end
      end
      _CHECK_INPUT_ key_push: K_SPACE do
        _SET_ vx: 4
        _SET_ vy: -9
        _HALT_
        _RETURN_ do
          state_normal
        end
      end
      _GET_ :x, control: [:_PARENT_, :bar] do |x:|
        _SET_ x: x + 45
      end
      _HALT_
      _RETURN_ do
        state_idle
      end
    end

    _DEFINE_ :curve do
      _GET_ [:x, :y] do |x:, y:|
        _SEND_ :_PARENT_, interrupt: true do
          _CREATE_ :Image, x: x, y: y, width: 10, height: 10 do
            _CIRCLE_ fill: true, x: 5, y: 5, r: 5, color: [255, 255, 255, 255]
            _MOVE_ [6], alpha: [255, 0]
            _DELETE_
          end
        end
      end
    end

    _DEFINE_ :aura do
      _GET_ [:x, :y] do |x:, y:|
        _SEND_ :_PARENT_, interrupt: true do
          _CREATE_ :Image, x: x, y: y, width: 10, height: 10 do
            _CIRCLE_ fill: true, x: 5, y: 5, r: 5, color: [255, 255, 0, 0]
            _MOVE_ [12], alpha: [255, 0]
            _DELETE_
          end
          _CREATE_ :Image, x: x, y: y, width: 10, height: 10 do
            _CIRCLE_ fill: true, x: 5, y: 5, r: 5, color: [255, 255, 128, 0]
            _MOVE_ [9], alpha: [255, 0]
            _DELETE_
          end
          _CREATE_ :Image, x: x, y: y, width: 10, height: 10 do
            _CIRCLE_ fill: true, x: 5, y: 5, r: 5, color: [255, 255, 255, 0]
            _MOVE_ [6], alpha: [255, 0]
            _DELETE_
          end
        end
      end
    end

    _DEFINE_ :state_normal do
      _CHECK_ equal: { wait: true } do
        _HALT_
        _RETURN_ do
          state_wait
        end
      end
      state_move
      _CHECK_ not_equal: { spin: 0 } do
        _CHECK_ not_equal: { boost: true } do
          curve
        end
      end
      _CHECK_ equal: { boost: true } do
        aura
      end
      _HALT_
      _RETURN_ do
        state_normal
      end
    end

    _DEFINE_ :state_wait do
      _CHECK_ equal: { wait: false } do
        _HALT_
        _RETURN_ do
          state_idle
        end
      end
      _HALT_
      _RETURN_ do
        state_wait
      end
    end

    state_wait
  end

  _DEFINE_ :state_miss do
    _GET_ :ball_rest do |ball_rest:|
      _SET_ ball_rest: ball_rest - 1
    end
    _SEND_ [:_ROOT_, :frame, :rest], interrupt: true do
      _UPDATE_
    end
    _CHECK_ equal: { ball_rest: 0 } do
      _RETURN_ do
        state_level_failure
      end
    end
    _SEND_ :message_miss, interrupt: true do
      _SET_ visible: true
      _MOVE_ [10], alpha: [128, 255], angle: [45, -20]
      _MOVE_ [20, easing: :out_bounce], angle: [-20, 0]
      _WAIT_ count: 10
      _GET_ [:x, :y], control: [:_PARENT_, :bar] do |x:, y:|
        _SEND_ [:_PARENT_, :ball], interrupt: true do
            _SET_ x: x + BAR_INIT_WIDTH / 2 - 5
            _SET_ y: y - 10
            _SET_ visible: true
            _SET_ ready: true
        end
      end
      _MOVE_ [10], alpha: [255, 0]
      _SET_ visible: false
    end

    _HALT_
    _RETURN_ do
      _SET_ ball_alive: true
      state_normal
    end
  end

  _DEFINE_ :state_level_success do
    _SEND_ :message_success, interrupt: true do
      _SET_ visible: true
      _MOVE_ [10], alpha: [128, 255]
      _WAIT_ count: 30
      _MOVE_ [20], alpha: [255, 0]
      _SET_ visible: false
    end
    _WAIT_ count: 60
    _SELECT_
    _HALT_
    _RETURN_ do
      state_focus_play
    end
  end

  _DEFINE_ :_SELECT_ do
    _SEND_ :ball, interrupt: true do
      _SET_ wait: true
    end
    _SEND_ :bar, interrupt: true do
      _SET_ wait: true
    end
    _SEND_ :message_play_again, interrupt: true do
      _SET_ visible: true
      _MOVE_ [10], alpha: [128, 255]
    end
    _SEND_ :select_play, interrupt: true do
      _SET_ visible: true
      _MOVE_ [10], alpha: [128, 255]
    end
    _SEND_ :select_exit, interrupt: true do
      _SET_ alpha: 128
      _SET_ visible: true
    end
  end

  _DEFINE_ :state_focus_play do
    _CHECK_INPUT_ key_push: [K_LEFT, K_RIGHT] do
      _SEND_ :select_play, interrupt: true do
        _SET_ alpha: 128
      end
      _SEND_ :select_exit, interrupt: true do
        _SET_ alpha: 255
      end
      _HALT_
      _RETURN_ do
        state_focus_exit
      end
    end
    _CHECK_INPUT_ key_push: [K_SPACE] do
      _SEND_ :message_play_again, interrupt: true do
        _SET_ visible: false
      end
      _SEND_ :select_play, interrupt: true do
        _SET_ visible: false
      end
      _SEND_ :select_exit, interrupt: true do
        _SET_ visible: false
      end
      _SET_ ball_alive: true
      _SET_ ball_rest: 3
      _SEND_ [:_ROOT_, :frame, :rest], interrupt: true do
        _UPDATE_
      end
      _GET_ [:x, :y], control: :bar do |x:, y:|
        _SEND_ :ball, interrupt: true do
            _SET_ x: x + BAR_INIT_WIDTH / 2 - 5
            _SET_ y: y - 10
            _SET_ visible: true
            _SET_ ready: true
        end
      end
      _CHECK_ over: { bricks: 0 } do
        _SEND_ :bricks do
          _DELETE_
        end
      end
      _CREATE_BRICKS_
      _SET_ bricks: BRICK_ROWS * BRICK_COLS

      _SEND_ :message_ready, interrupt: true do
        _MOVE_ [12], alpha: [0, 255]
      end
      _WAIT_ count: 12

      _HALT_
      state_begin
    end
    _HALT_
    _RETURN_ do
      state_focus_play
    end
  end

  _DEFINE_ :state_focus_exit do
    _CHECK_INPUT_ key_push: [K_LEFT, K_RIGHT] do
      _SEND_ :select_play, interrupt: true do
        _SET_ alpha: 255
      end
      _SEND_ :select_exit, interrupt: true do
        _SET_ alpha: 128
      end
      _HALT_
      _RETURN_ do
        state_focus_play
      end
    end
    _CHECK_INPUT_ key_push: [K_SPACE] do
      _HALT_
      _EXIT_
    end
    _HALT_
    _RETURN_ do
      state_focus_exit
    end
  end

  _DEFINE_ :state_level_failure do
    _SEND_ :message_failure, interrupt: true do
      _SET_ visible: true
      _MOVE_ [10], alpha: [128, 255]
      _WAIT_ count: 30
      _MOVE_ [20], alpha: [255, 0]
      _SET_ visible: false
    end
    _WAIT_ count: 60
    _SELECT_
    _WAIT_ count: 10
    _HALT_
    _RETURN_ do
      state_focus_play
    end
  end

  _DEFINE_ :state_normal do
    _CHECK_ equal: { ball_alive: false } do
      _HALT_
      _RETURN_ do
        state_miss
      end
    end
    _CHECK_ equal: { bricks: 0 } do
      _SEND_ :bricks, interrupt: true do
        _DELETE_
      end
      _HALT_
      _SEND_ :ball, interrupt: true do
        _RESET_
      end
      _RETURN_ do
        state_level_success
      end
    end
    _HALT_
    _RETURN_ do
      state_normal
    end
  end

  _DEFINE_ :state_ready do
    GC.start
    _WAIT_ count:6
    state_normal
  end

  _DEFINE_ :state_setup do
    _SET_ ball_rest: 3
    _SEND_ :bar, interrupt: true do
      _SET_ x: BAR_INIT_X
      _SET_ y: BAR_INIT_Y
      _SET_ vx: 0
    end
    _SEND_ :ball, interrupt: true do
      _SET_ x: BALL_INIT_X
      _SET_ y: BALL_INIT_Y
      _SET_ vx: 0
      _SET_ vy: 0
      _SET_ spin: 0
    end
    _CREATE_BRICKS_

    _MOVE_ [30, easing: :out_sine], alpha: [0, 255]

    _RETURN_ do
      state_begin
    end
  end

  _DEFINE_ :state_begin do
    _CHECK_INPUT_ key_push: K_SPACE do
      _SEND_ :ball, interrupt: true do
        _SET_ wait: false
      end
      _SEND_ :bar, interrupt: true do
        _SET_ wait: false
      end
      _HALT_
      _SEND_ :message_ready, interrupt: true do
        _MOVE_ [12], alpha: [255, 0]
      end
      _RETURN_ do
        state_ready
      end
    end

    _HALT_
    _RETURN_ do
      state_begin
    end
  end

  _HALT_
  state_setup
end

_LOOP_ do
  _HALT_
end