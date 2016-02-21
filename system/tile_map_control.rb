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

#※子コントロール群は描画対象にならないので注意

class TileMapControl < LayoutControl

  attr_accessor :map_array
  attr_accessor :image_array
  attr_accessor :map_x
  attr_accessor :map_y
  attr_accessor :size_x
  attr_accessor :size_y
  attr_accessor :z

  def initialize(options, yield_block_stack, root_control, &block)

    @map_array = options[:map_array] || []
    @image_array = options[:image_array] || []
    @map_x = options[:map_x] || 0
    @map_y = options[:map_y] || 0
    @size_x = options[:size_x] || 1
    @size_y = options[:size_y] || 1
    @z = options[:z] || 0

    super
  end

  #描画
  def update(offset_x, offset_y, target, 
              parent_control_width, 
              parent_control_height, 
              mouse_pos_x,
              mouse_pos_y )
    super

    #描画オブジェクトを持ち、かつ可視でなければ戻る
    return 0, 0 unless @image_array and @visible

    dx, dy = check_align(parent_control_width, parent_control_height)

    target.draw_tile( @x + @offset_x + offset_x + dx,
                      @y + @offset_y + offset_y + dy, 
                      @map_array, 
                      @image_array, 
                      @map_x, 
                      @map_y, 
                      @size_x, 
                      @size_y, 
                      @z)

    return check_float
  end

  def _SET_IMAGE_(argument, options, yield_block_stack)
    @image_array[argument] = Image.load(options[:file_path])
  end

  def _SET_IMAGE_MAPPING_(argument, options, yield_block_stack)
    @image_array = Image.load_tiles(options[:file_path], 
                                    options[:x_count] || 1, 
                                    options[:y_count] || 1, 
                                    options[:share_switch] || true)
  end

  def _SET_TILE_(argument, options, yield_block_stack)
    @map_array[options[:x]][options[:y]] = options[:id]
  end

end
