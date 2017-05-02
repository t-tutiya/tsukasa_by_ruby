#! ruby -E utf-8

###############################################################################
#TSUKASA for DXRuby ver2.2(2017/2/14)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2017> <tsukasa TSUCHIYA>
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

require_relative './Control.rb'

module Tsukasa

module Layoutable
  #座標
  attr_accessor  :x
  attr_accessor  :y
  attr_reader  :absolute_x
  attr_reader  :absolute_y

  def initialize(system, x: 0, y: 0, **options, &block)
    @x = x #描画Ｘ座標
    @y = y #描画Ｙ座標
    @absolute_x = 0
    @absolute_y = 0
    super
  end

  def update(absolute_x, absolute_y)
    @absolute_x = @x + absolute_x
    @absolute_y = @y + absolute_y
    super(@absolute_x, @absolute_y)
  end
end

class Layout < Control
  include Layoutable
  def render(offset_x, offset_y, target)
    #自身の描画座標を補正する
    super(@x + offset_x, @y + offset_y, target)
  end
end

end