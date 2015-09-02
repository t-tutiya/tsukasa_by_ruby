#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby  α１
#汎用ゲームエンジン「司（TSUKASA）」 for DXRuby
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

class TileImageControl < Control

  #Imageのキャッシュ機構の簡易実装
  #TODO:キャッシュ操作：一括クリア、番号を指定してまとめて削除など
  @@tile_image_cache = Hash.new
  #キャッシュされていない画像パスが指定されたら読み込む
  @@tile_image_cache.default_proc = ->(hsh, key) {
    hsh[key] = Image.load(key)
  }

  def initialize(options, inner_options, root_control)
    super
    if options[:entity]
      entity = options[:entity]
    else
      entity = @@tile_image_cache[options[:file_path]]
    end

    entities = entity.slice_tiles(options[:x_count] || 1, 
                                 options[:y_count] || 1)

    entities.each.with_index(options[:start_index] || 0) do |image, index|
      #TODO;インデックスと逆順に格納されている。直すべきか検討
      interrupt_command([:_CREATE_, 
                        {
                          :_ARGUMENT_ => :ImageControl,
                          :entity => image,
                          :id => index,
                          :float_mode => options[:float_mode],
                          :visible => false
                        }, inner_options])
    end
  end

  def dispose()
    #TODO：キャッシュ機構が作り込まれてないのでここで削除できない
    #@entity.dispose
    super
  end
end