#! ruby -E utf-8

###############################################################################
#TSUKASA for DXRuby ver2.2(2017/1/28)
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

require_relative './DrawableLayout.rb'

module Tsukasa

class TileMap < DrawableLayout

  attr_accessor :map_array
  attr_accessor :image_array
  attr_accessor :map_x
  attr_accessor :map_y
  attr_accessor :size_x
  attr_accessor :size_y

  def initialize( system, 
                  _IMAGE_API_: DXRuby::Image,
                  **options, 
                  &block)
    @_IMAGE_API_ = _IMAGE_API_
    
    options[:width] = options[:width] || 32
    options[:height] = options[:height] || 32

    @map_array = options[:map_array] || []
    @image_array = options[:image_array] || []
    @map_x = options[:map_x] || 0
    @map_y = options[:map_y] || 0
    @size_x = options[:size_x] || 1
    @size_y = options[:size_y] || 1

    super
  end

  def dispose()
    @image_array.each do |image|
      image.dispose
    end
    super
  end

  def render(offset_x, offset_y, target)
    #描画オブジェクトを持ち、かつ可視でなければ戻る
    return super unless @image_array

    @entity.draw_tile(0, 0, 
                      @map_array, @image_array, 
                      @map_x, @map_y, 
                      @size_x, @size_y, 
                      @z)

    return super
  end

  def _SET_TILE_(_ARGUMENT_: nil, path:)
    begin
      if _ARGUMENT_
        @image_array[_ARGUMENT_] = @_IMAGE_API_.load(path)
      else
        @image_array.push(@_IMAGE_API_.load(path))
      end
    rescue DXRuby::DXRubyError
      warn "#{path}の読みこみに失敗しました"
    end
  end

  def _SET_TILE_GROUP_(_ARGUMENT_: nil, path:, 
                        x_count: 1, y_count: 1, share_switch: false )
    begin
      image_array = @_IMAGE_API_.load_tiles(path, 
                                      x_count, y_count, share_switch)
    rescue DXRuby::DXRubyError
      warn "#{path}の読みこみに失敗しました"
    end
    
    if _ARGUMENT_
      counter = _ARGUMENT_
      image_array.each do |image|
        @image_array[counter] = image
        counter += 1
      end
    else
      @image_array += image_array
    end
  end

  def _MAP_STATUS_(_ARGUMENT_: nil, x: 0, y: 0)
    if _ARGUMENT_
      @map_array[x][y] = _ARGUMENT_
    else
      #ブロックが付与されているならそれを実行する
      unshift_command_block({status: @map_array[x][y]})
    end
  end

end

end
