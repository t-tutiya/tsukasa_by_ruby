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

require_relative './rule_shader_control.rb'

require_relative './sound_control.rb'

require_relative './text_page_control.rb'

require_relative './script_compiler.rb'

#TODO：モジュールであるべきか？
class Tsukasa < LayoutControl
  attr_reader  :_USER_DATA_
  attr_reader  :_GLOBAL_DATA_
  attr_reader  :default_control
  attr_reader  :function_list
  attr_accessor  :sleep_mode

  def initialize(options)
    @root_control = self
    #ゲーム全体で共有するセーブデータ
    @_GLOBAL_DATA_ = {
      :_DEBUG_ => false,
      :_SAVE_DATA_PATH_ => "./data/",
      :_GLOBAL_DATA_FILENAME_ => "global_data.bin",
      :_USER_DATA_FILENAME_ => "_user_data.bin",
      :_QUICK_DATA_FILENAME_ => "_quick_data.bin",
    }
    
    #スリープ状態にあるコントロールが存在するかどうかを示す
    @sleep_mode = false

    #コマンドに設定されているデフォルトの送信先クラスのIDディスパッチテーブル
    @default_control = {
      :TextPageControl   => :default_text_page_control0,
      :RenderTargetContainer => :default_RenderTarget_container,
      :Anonymous       => :anonymous,
    }
    options[:script_file_path] = "./system/bootstrap_script.rb"
    options[:id] = :default_rendertarget_container
    options[:redenr_target] = false unless options[:redenr_target]

    #ラベル関連
    @label_name = options[:label_name] || nil
    @label_id = options[:label_id] || 0
    @label_options = options[:label_options] || nil

    @_USER_DATA_ = {}
    @_GLOBAL_DATA_ = {}

    super(options, {}, @root_control)
  end

  def siriarize(options = {})

    options.update({
      :label_name => @label_name,
      :label_id => @label_id,
      :label_options => @label_options,
    })

    return super(options)
  end

  def render(offset_x, offset_y, target, parent_size = {:width => Window.width, :height => Window.width})
    super
  end

  def command_label(options, inner_options)
    unless @_USER_DATA_[:_READ_FRAG_]
      @_USER_DATA_[:_READ_FRAG_] = {} 
    end

    if not @label_name and not options[:name] 
      raise
    end

    #ラベル名が指定されていて、かつ保存されているラベル名と異なる
    if options[:name] and (@label_name != options[:name])
      #ラベル名を保存する
      @label_name = options[:name]
      #ラベルのIDをクリアする
      @label_id = 0
    else
      #ラベルのIDをインクリメントする
      @label_id += 1
    end

    if not @label_title and not options[:title] 
      raise
    end

    #ベースラベルタイトルの存在チェック
    if options[:title]
      @label_title = options[:title]
    end

    unless @_USER_DATA_[:_READ_FRAG_][@label_name]
      @_USER_DATA_[:_READ_FRAG_][@label_name] = []
    end

    if @_USER_DATA_[:_READ_FRAG_][@label_name][@label_id]
      #グローバルデータ領域に既読であると通知
      @_GLOBAL_DATA_[:_NOT_READ_] = false
    else
      #グローバルデータ領域に未読状態であると通知
      @_GLOBAL_DATA_[:_NOT_READ_] = true

      #既読フラグを立てる
      @_USER_DATA_[:_READ_FRAG_][@label_name][@label_id] = @label_title
    end
    #pp @_USER_DATA_[:_READ_FRAG_]
  end
end
