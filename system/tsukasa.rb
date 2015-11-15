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

require_relative './module_layoutable.rb'
require_relative './module_drawable.rb'

require_relative './image_control.rb'

require_relative './layout_control.rb'

require_relative './rendertarget_control.rb'
require_relative './colorkey_control.rb'

require_relative './tile_image_control.rb'

require_relative './rule_shader_control.rb'

require_relative './midi_control.rb'
require_relative './sound_control.rb'

require_relative './char_control.rb'
require_relative './text_page_control.rb'

require_relative './script_compiler.rb'

#TODO：モジュールであるべきか？
class Tsukasa < RenderTargetControl

  #システム全体で共有されるデータ群。保存対象。
  def _SYSTEM_
    @_SYSTEM_
  end
  #個別のセーブデータを表すデータ群。保存対象。
  def _LOCAL_
    @_LOCAL_
  end
  #一時的に管理するデータ群。保存対象ではない。
  def _TEMP_
    @_TEMP_
  end

  def close?
    @close
  end

  def mouse_x
    Input.mouse_x
  end
  def mouse_x=(args)
    Input.set_mouse_pos(args, Input.mouse_y)
  end

  def mouse_y
    Input.mouse_y
  end
  def mouse_y=(args)
    Input.set_mouse_pos(Input.mouse_x, args)
  end

  #マウスカーソルの形状を設定する。
    #マウスカーソル定数
    #IDC_APPSTARTING 標準の矢印カーソルと小さい砂時計カーソル
    #IDC_ARROW 標準の矢印カーソル
    #IDC_CROSS 十字カーソル
    #IDC_HAND ハンドカーソル
    #IDC_HELP 矢印と疑問符
    #IDC_IBEAM アイビーム（ 縦線）カーソル
    #IDC_NO 禁止カーソル（ 円に左上から右下への斜線）
    #IDC_SIZEALL 4 方向の矢印カーソル
    #IDC_SIZENESW 右上と左下を指す両方向矢印カーソル
    #IDC_SIZENS 上下を指す両方向矢印カーソル
    #IDC_SIZENWSE 左上と右下を指す両方向矢印カーソル
    #IDC_SIZEWE 左右を指す両方向矢印カーソル
    #IDC_UPARROW 上を指す垂直の矢印カーソル
    #IDC_WAIT 砂時計カーソル
  attr_reader  :cursor_type
  def cursor_type=(args)
    @cursor_type = args
    Input.set_cursor(args)
  end

  #マウスカーソルの表示／非表示を設定する
  attr_reader  :cursor_visible
  def cursor_visible=(args)
    @cursor_visible = args
    Input.mouse_enable = args
  end

  #タイトルバーののキャプション
  def caption(args)
    @caption = Window.caption
  end
  def caption=(args)
    @caption = args
    Window.caption = args
  end

  #タイトルバーのアイコン画像
  attr_reader  :icon_file_path
  def icon_file_path=(args)
    @icon_file_path = args
    Window.load_icon(path)
  end

  attr_reader  :default_control
  attr_reader  :function_list

  def initialize(options)
    #アプリ終了フラグ
    @close = false

    @root_control = self
    #ゲーム全体で共有するセーブデータ
    @_SYSTEM_ = {
      :_DEBUG_ => false,
      :_SAVE_DATA_PATH_ => "./data/",
      :_SYSTEM_FILENAME_ => "system_data.bin",
      :_LOCAL_FILENAME_ => "_local_data.bin",
      :_QUICK_DATA_FILENAME_ => "_quick_data.bin",
    }

    @_LOCAL_ = {}
    @_TEMP_ = {}

    #コマンドに設定されているデフォルトの送信先クラスのIDディスパッチテーブル
    @default_control = {
      :TextLayer => :text0,
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

    super(options, 
          { :block_stack => []}, 
          @root_control)
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

  def command__RESIZE_(options, inner_options)
    Window.resize(options[:width], 
                  options[:height])
  end

  #スクリーンショットキャプチャ
  def command__CAPTURE_SS_(options, inner_options)
    Window.get_screen_shot("./data/" + options[:_ARGUMENT_], 
                           options[:format] || FORMAT_PNG)
  end

=begin
  def command__FULL_SCREEN_(options, inner_options)
    Window.full_screen = options[:_ARGUMENT_]
  end
=end

  def command__EXIT_(options, inner_options)
    @close = true
  end

  def command_label(options, inner_options)
    unless @_LOCAL_[:_READ_FRAG_]
      @_LOCAL_[:_READ_FRAG_] = {} 
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

    unless @_LOCAL_[:_READ_FRAG_][@label_name]
      @_LOCAL_[:_READ_FRAG_][@label_name] = []
    end

    if @_LOCAL_[:_READ_FRAG_][@label_name][@label_id]
      #グローバルデータ領域に既読であると通知
      @_SYSTEM_[:_NOT_READ_] = false
    else
      #グローバルデータ領域に未読状態であると通知
      @_SYSTEM_[:_NOT_READ_] = true

      #既読フラグを立てる
      @_LOCAL_[:_READ_FRAG_][@label_name][@label_id] = @label_title
    end
    #pp @_LOCAL_[:_READ_FRAG_]
  end

  def command_on_requested_close(options, inner_options)
    #閉じるボタンがクリックされた場合
    if Input.requested_close?
      eval_block(options, inner_options[:block_stack], &inner_options[:block])
    end
    #イベントコマンドはコマンドリストに残り続ける
    push_command_to_next_frame(:on_requested_close, options, inner_options)
  end
end
