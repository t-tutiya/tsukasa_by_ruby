#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver1.2(2016/3/1)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2016> <tsukasa TSUCHIYA>
#
#This software is provided 'as-is', without any express or implied
#warranty. In no event will the authors be held liable for any damages
#arising from the use of this software.
#
#Permission is granted to anyone to use this software for any purpose,
#including commercial applications, and to alter it and redistribute it
#freely, subject to the following restrictions:
#
#   1. The origin of this software must not be misrepresented; you must not
#   claim that you wrote the original software. If you use this software
#   in a product, an acknowledgment in the product documentation would be
#   appreciated but is not required.
#
#   2. Altered source versions must be plainly marked as such, and must not be
#   misrepresented as being the original software.
#
#   3. This notice may not be removed or altered from any source
#   distribution.
#
#[The zlib/libpng License http://opensource.org/licenses/Zlib]
###############################################################################

class LayoutControl < Control
  include Layoutable
  include Clickable

  #描画
  def update(offset_x, offset_y, target, 
              parent_control_width, parent_control_height, 
              mouse_pos_x, mouse_pos_y)
    #可視でなければ戻る
    return 0, 0 unless @visible

    dx, dy = check_align(parent_control_width, parent_control_height)

    #次フレームのクリッカブル判定に使うマウスカーソル座標を取得
    @mouse_pos_x = mouse_pos_x
    @mouse_pos_y = mouse_pos_y

    super(offset_x + @x + @offset_x + dx, 
          offset_y + @y + @offset_y + dy, 
          target, 
          @width, @height, 
          mouse_pos_x - @x, mouse_pos_y - @y)

    return check_float
  end


  def serialize(control_name = :LayoutControl, **options)
    return super(control_name, options)
  end
end
