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

#イメージコントロール
class ImageControl < Control
  include Drawable

  #Imageのキャッシュ機構の簡易実装
  #TODO:キャッシュ操作：一括クリア、番号を指定してまとめて削除など
  @@image_cache = Hash.new
  #キャッシュされていない画像パスが指定されたら読み込む
  @@image_cache.default_proc = ->(hsh, key) {
    hsh[key] = Image.load(key)
  }

  def initialize(options, inner_options, root_control)
    super
    command_load_image(options, inner_options)
  end

  def dispose()
    #TODO：キャッシュ機構が作り込まれてないのでここで削除できない
    #@entity.dispose
    super
  end

  def command_load_image(options, inner_options)

    #イメージの分割指定がある場合
    if options[:tiles]
      @file_path = options[:file_path]

      entities = @@image_cache[@file_path].slice_tiles(
                                                  options[:x_count] || 1, 
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
    else

      #実体から初期化する
      if options[:entity]
        @file_path = nil
        @entity = options[:entity]

        if options[:width]
          @width = options[:width]
        else
          @width  = @entity.width
        end

        if options[:height]
          @height = options[:height]
        else
          @height  = @entity.height
        end

      #ファイルパスから初期化する
      elsif options[:file_path]
        @file_path = options[:file_path]
        @entity = @@image_cache[@file_path]

        #縦横幅の更新
        @width  = @entity.width
        @height = @entity.height

      #空コントロールとして初期化する
      else
        @file_path = nil
        @entity = Image.new(1,1,[0,0,0])

        #縦横幅の更新
        @width  = 1
        @height = 1
      end

      @real_width = @entity.width
      @real_height = @entity.height
    end

    #同名のtksファイルがあれば読み込む
    if options[:file_path]
      tks_path = File.dirname( options[:file_path]) + "/" + 
             File.basename(options[:file_path], ".*") + ".tks"
      rb_path = File.dirname( options[:file_path]) + "/" + 
             File.basename(options[:file_path], ".*") + ".rb"
      if File.exist?(tks_path)
        @command_list += @script_compiler.commands({:script_path => tks_path})
      end
      if File.exist?(rb_path)
        @command_list += @script_compiler.commands({:script_path => rb_path})
      end
    end
  end
end
