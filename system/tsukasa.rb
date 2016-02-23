#! ruby -E utf-8
# coding: utf-8

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

require 'dxruby'
require 'pp'

require_relative './control.rb'

require_relative './module_layoutable.rb'
require_relative './module_drawable.rb'
require_relative './module_clickable.rb'

require_relative './image_control.rb'

require_relative './layout_control.rb'

require_relative './rendertarget_control.rb'
require_relative './colorkey_control.rb'

require_relative './tile_map_control.rb'

require_relative './rule_shader_control.rb'

require_relative './sound_control.rb'

require_relative './char_control.rb'
require_relative './text_page_control.rb'

require_relative './script_compiler.rb'

#TODO：モジュールであるべきか？
class Tsukasa < RenderTargetControl
  include Clickable

  #システム全体で共有されるデータ群。保存対象。
  #_LOAD_で初期化するためにwrite属性あり
  attr_reader  :_SYSTEM_

  #個別のセーブデータを表すデータ群。保存対象。
  #_LOAD_で初期化するためにwrite属性あり
  attr_reader  :_LOCAL_

  #一時的に管理するデータ群。保存対象ではない。
  attr_reader  :_TEMP_

  attr_reader  :_DEFAULT_CONTROL_

  #マウスカーソルの表示／非表示を設定する
  attr_accessor  :cursor_visible

  attr_reader  :function_list

  attr_reader  :script_compiler
  attr_reader  :script_parser
end

class Tsukasa < RenderTargetControl

  def initialize(options)
    #アプリ終了フラグ
    @close = false

    @root_control = self

    #システムデータストア
    @_SYSTEM_ = {}
    #ローカルデータストア
    @_LOCAL_ = {}
    #一時データストア
    @_TEMP_ = {}
    #コマンドに設定されているデフォルトの送信先クラスのIDディスパッチテーブル
    @_DEFAULT_CONTROL_ = {}

    options[:id] = :default_rendertarget_container

    @script_compiler = ScriptCompiler.new(self)
    #パーサー
    @script_parser = {}

    options[:command_list] = [[:_INCLUDE_,
                        "./default/bootstrap_script.rb",
                        {}, 
                        nil, nil, nil]]

    #カーソル歌詞設定
    @cursor_visible = true

    super(options, nil, @root_control)
  end

  def update(offset_x, offset_y, target, 
              parent_control_width = Window.width, 
              parent_control_height = Window.width, 
              mouse_pos_x = Input.mouse_x,
              mouse_pos_y = Input.mouse_y)

    #mマウスカーソルが不可視で、かつカーソルが画像の外にある場合
    unless @cursor_visible
      if  Input.mouse_x < 0 or @width  < Input.mouse_x or 
          Input.mouse_y < 0 or @height < Input.mouse_y
        #カーソルを表示する
        Input.mouse_enable = true
      else
        #カーソルを不可視に戻す
        Input.mouse_enable = false
      end
    end
    super
  end

  def close
    @close = true
  end

  def close?
    @close
  end

end

class Tsukasa < RenderTargetControl
  def _SCRIPT_PARSER_(argument, options, yield_block_stack)
    require_relative options[:file_path]
    @script_parser[options[:ext_name]] = [
      Module.const_get(options[:parser]).new,
      Module.const_get(options[:parser])::Replacer.new]
  end

  #ネイティブコードを読み込む
  def _LOAD_NATIVE_(argument, options, yield_block_stack)
    raise unless argument
    require argument
  end

  #データセーブ
  #TODO：保存先パスや名称は将来的には外部から与えるようにしたい
  def _SAVE_(argument, options, yield_block_stack)
    raise unless argument.kind_of?(Numeric)
    #グローバルデータ
    if argument == 0
      db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + 
                      @_SYSTEM_[:_SYSTEM_FILENAME_])
      db.transaction do
        db["key"] = @_SYSTEM_
      end
    #ユーザーデータ
    #任意の接尾字を指定する
    elsif argument
      db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + argument.to_s +
                      @_SYSTEM_[:_LOCAL_FILENAME_])
      db.transaction do
        db["key"] = @_LOCAL_
      end
    else
      #セーブファイル指定エラー
      pp "対象セーブファイルが指定されていません"
      raise 
    end
  end

  def _LOAD_(argument, options, yield_block_stack)
    raise unless argument.kind_of?(Numeric)
    #グローバルデータ
    if argument == 0
      db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + 
                      @_SYSTEM_[:_SYSTEM_FILENAME_])
      db.transaction do
        @_SYSTEM_ = db["key"]
      end
    #ユーザーデータ
    #任意の接尾字を指定する
    elsif argument
      db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + argument.to_s +
                      @_SYSTEM_[:_LOCAL_FILENAME_])
      db.transaction do
        @_LOCAL_ = db["key"]
      end
    else
      #セーブファイル指定エラー
      pp "対象セーブファイルが指定されていません"
      raise 
    end
  end

end
