#! ruby -E utf-8
# coding: utf-8

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

require 'dxruby'
require 'pp'

require_relative './control.rb'
require_relative './module_clickable.rb'
require_relative './module_drawable.rb'

require_relative './image_control.rb'

require_relative './layout_control.rb'
require_relative './tile_image_control.rb'

require_relative './sound_control.rb'

require_relative './text_page_control.rb'

require_relative './script_compiler.rb'

#TODO：モジュールであるべきか？
class Tsukasa < LayoutControl
  attr_reader  :_USER_DATA_
  attr_reader  :_GLOBAL_DATA_
  attr_reader  :_MODE_STATUS_
  attr_reader  :default_control
  attr_reader  :function_list

  def initialize(options)
    @root_control = self
    #個別ユーザーデータ領域
    @_USER_DATA_ = {}
    #ゲーム全体で共有するセーブデータ
    @_GLOBAL_DATA_ = {
      :_DEBUG_ => false,
      :_SAVE_DATA_PATH_ => "./data/",
      :_GLOBAL_DATA_FILENAME_ => "global_data.bin",
      :_USER_DATA_FILENAME_ => "_user_data.bin",
      :_QUICK_DATA_FILENAME_ => "_quick_data.bin",
    }
    #各種モードの管理
    @_MODE_STATUS_ = {
      :wake => true,
      #idle_modeはシステムが管理する為、ここでは扱わない
    }
    #コマンドに設定されているデフォルトの送信先クラスのIDディスパッチテーブル
    @default_control = {
      :TextPageControl   => :default_text_page_control0,
      :RenderTargetContainer => :default_RenderTarget_container,
      :Anonymous       => :anonymous,
    }
    options[:script_file_path] = "./system/bootstrap_script.rb"
    options[:id] = :default_rendertarget_container
    options[:redenr_target] = false unless options[:redenr_target]
    super(options, {}, @root_control)
  end
end
