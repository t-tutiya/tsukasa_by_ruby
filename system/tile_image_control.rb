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

class TileImageControl < LayoutControl

  #Imageのキャッシュ機構の簡易実装
  #TODO:キャッシュ操作：一括クリア、番号を指定してまとめて削除など
  @@tile_image_cache = Hash.new
  #キャッシュされていない画像パスが指定されたら読み込む
  @@tile_image_cache.default_proc = ->(hsh, key) {
    hsh[key] = Image.load(key)
  }

  attr_accessor :file_path
  attr_accessor :x_count
  attr_accessor :y_count
  attr_accessor :start_index
  attr_accessor :float_x
  attr_accessor :float_y

  def initialize(argument, options, 
                  block_stack = [], yield_block_stack = [], block = nil, 
                  root_control)
    super

    @file_path = options[:file_path]
    @x_count = options[:x_count] || 1
    @y_count = options[:y_count] || 1
    @start_index = options[:start_index] || 0
    @float_x = options[:float_x]
    @float_y = options[:float_y]

    if options[:entity]
      entity = options[:entity]
    else
      entity = @@tile_image_cache[@file_path]
    end

    entities = entity.slice_tiles(@x_count, @y_count)

    command_list = []
    entities.each.with_index(@start_index) do |image, index|
      command_list.push([:_CREATE_, 
                        :ImageControl,
                        { :entity => image,
                          :id => index,
                          :float_x => @float_x,
                          :float_y => @float_y,
                          :visible => false
                        }, 
                        {}])
    end
    eval_commands(command_list)
  end

  def serialize(control_name = :TileImageControl, **options)
    
    options.update({
      :file_path => @file_path,
      :x_count => @x_count,
      :y_count => @y_count,
      :start_index => @start_index,
      :float_x => @float_x,
      :float_y => @float_y,
    })

    options[:id] = @id

    #オプションを生成
    return [:_CREATE_, control_name, options, {}]
    #return super(control_name, options)
  end

  def dispose()
    #TODO：キャッシュ機構が作り込まれてないのでここで削除できない
    #@entity.dispose
    super
  end
end