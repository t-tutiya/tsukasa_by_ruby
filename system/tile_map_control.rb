#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver1.0(2015/12/24)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2015> <tsukasa TSUCHIYA>
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

class TileMapControl < Control
  include Layoutable

  attr_reader :file_path
  def file_path=(arg)
    @file_path = arg
    @update_flag = true
  end

  attr_reader :map_base_x_count
  def map_base_x_count=(arg)
    @map_base_x_count = arg
    @update_flag = true
  end

  attr_reader :map_base_y_count
  def map_base_y_count=(arg)
    @map_base_y_count = arg
    @update_flag = true
  end

  attr_reader :share_switch
  def share_switch=(arg)
    @share_switch = arg
    @update_flag = true
  end

  attr_accessor :image_array
  attr_accessor :map_x
  attr_accessor :map_y
  attr_accessor :size_x
  attr_accessor :size_y
  attr_accessor :z

  def initialize(argument, options, yield_block_stack = [], block = nil, 
                  root_control)

    @file_path = options[:file_path]
    @map_base_x_count = options[:map_base_x_count] || 1
    @map_base_y_count = options[:map_base_y_count] || 1
    @share_switch = options[:share_switch] || true
    @update_flag = true

    @map_array = options[:image_array]

    @map_x = options[:map_x] || 0
    @map_y = options[:map_y] || 0
    @size_x = options[:size_x] || 1
    @size_y = options[:size_y] || 1
    @z = options[:z] || 0

    super
  end
  
  #描画
  def render(offset_x, offset_y, target, 
              parent_control_width, 
              parent_control_height, 
              mouse_pos_x,
              mouse_pos_y )
    if @update_flag and @file_path
      @image_array = Image.load_tiles(@file_path, 
                                    @map_base_x_count, 
                                    @map_base_y_count, 
                                    @share_switch)
      @update_flag = false
    end

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

  def serialize(control_name = :RenderTargetControl, **options)
    
    options.update({
    })

    return super(control_name, options)
  end

  def _SET_TILE_(argument, options, yield_block_stack)
    @map_array[options[:x]][options[:y]] = options[:id]
  end

end
