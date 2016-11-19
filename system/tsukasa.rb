#! ruby -E utf-8
# coding: utf-8

#$VERBOSE = true

###############################################################################
#TSUKASA for DXRuby ver2.0(2016/8/28)
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

$dxruby_no_include = true #DXRubyがグローバル空間にincludeされるのを抑制する
require 'dxruby'
require 'pp'

#キーコード定数／パッド定数／マウスボタン定数
require_relative './Constant.rb'
#例外（TskasaError）
require_relative './Exception.rb'
#汎用リソースキャッシュ管理機構
require_relative './CacheManager.rb'
#スクリプトコンパイラ
require_relative './ScriptCompiler.rb'

#ベースコントロール
require_relative './Control.rb'

#ヘルパーコントロール
require_relative './Layoutable.rb'
require_relative './Drawable.rb'

#コントロール群
require_relative './Image.rb'
require_relative './Layout.rb'
require_relative './DrawableLayout.rb'
require_relative './ClickableLayout.rb'
require_relative './Sound.rb'
require_relative './Char.rb'
require_relative './Data.rb'

#複合コントロール群
require_relative './TextPage.rb'
require_relative './TileMap.rb'
require_relative './RuleShader.rb'

module Tsukasa

class Window < Layout
  attr_reader  :function_list

  attr_reader  :script_compiler
  attr_reader  :script_parser

  def mouse_x=(arg)
    DXRuby::Input.set_mouse_pos(arg, DXRuby::Input.mouse_y)
  end

  def mouse_y=(arg)
    DXRuby::Input.set_mouse_pos(DXRuby::Input.mouse_x, arg)
  end

  def initialize(options)
    #アプリ終了フラグ
    @close = false

    #パーサー
    @script_compiler = ScriptCompiler.new
    @script_parser = {}

    options[:command_list] = [[ :_INCLUDE_, 
                            {_ARGUMENT_: "./default/bootstrap_script.rb"},nil]]

    super(options, nil, self, self)
  end

  def close
    @close = true
  end

  def close?
    @close
  end

  def _SCRIPT_PARSER_(yield_stack, options)
    require_relative options[:path]
    @script_parser[options[:ext_name]] = [
      Module.const_get(options[:parser]).new,
      Module.const_get(options[:parser])::Replacer.new]
  end

  #ネイティブコードを読み込む
  def _LOAD_NATIVE_(yield_stack, options)
    raise unless options[:_ARGUMENT_]
    require options[:_ARGUMENT_]
  end

  #データセーブ
  def _SAVE_(yield_stack, options)
    raise unless options[:_ARGUMENT_].kind_of?(Numeric)
    #グローバルデータ
    if options[:_ARGUMENT_] == 0
      db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + 
                      @_SYSTEM_[:_SYSTEM_FILENAME_])
      db.transaction do
        db["key"] = @_SYSTEM_
      end
    #ユーザーデータ
    #任意の接尾字を指定する
    elsif options[:_ARGUMENT_]
      db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + options[:_ARGUMENT_].to_s +
                      @_SYSTEM_[:_LOCAL_FILENAME_])
      db.transaction do
        db["key"] = @_LOCAL_
      end
    else
      #セーブファイル指定エラー
      raise(Tsukasa::TsukasaError, "対象セーブファイルが指定されていません")
    end
  end

  def _LOAD_(yield_stack, options)
    raise unless options[:_ARGUMENT_].kind_of?(Numeric)
    #グローバルデータ
    if options[:_ARGUMENT_] == 0
      db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + 
                      @_SYSTEM_[:_SYSTEM_FILENAME_])
      db.transaction do
        @_SYSTEM_ = db["key"]
      end
    #ユーザーデータ
    #任意の接尾字を指定する
    elsif options[:_ARGUMENT_]
      db = PStore.new(@_SYSTEM_[:_SAVE_DATA_PATH_] + options[:_ARGUMENT_].to_s +
                      @_SYSTEM_[:_LOCAL_FILENAME_])
      db.transaction do
        @_LOCAL_ = db["key"]
      end
    else
      #セーブファイル指定エラー
      raise(Tsukasa::TsukasaError, "対象セーブファイルが指定されていません")
    end
  end
end

end
