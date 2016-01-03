#! ruby -E utf-8
# coding: utf-8

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

require_relative './sound_control.rb'

require_relative './char_control.rb'
require_relative './text_page_control.rb'

require_relative './script_compiler.rb'

#TODO：モジュールであるべきか？
class Tsukasa < RenderTargetControl

  #システム全体で共有されるデータ群。保存対象。
  attr_accessor  :_SYSTEM_
  #個別のセーブデータを表すデータ群。保存対象。
  attr_accessor  :_LOCAL_
  #一時的に管理するデータ群。保存対象ではない。
  attr_accessor  :_TEMP_

  attr_reader  :_DEFAULT_CONTROL_

  attr_accessor  :close
  def close?
    @close
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

  #タイトルバーの文字列
  def caption
    Window.caption
  end
  def caption=(args)
    Window.caption = args
  end

  #タイトルバーのアイコン
  attr_reader  :icon_path
  def icon_path=(args)
    @icon_path = args
    Window.load_icon(@icon_path)
  end

  #マウスカーソルの表示／非表示を設定する
  attr_accessor  :cursor_visible

  attr_reader  :function_list
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

    options[:command_list] = [[:_INCLUDE_,
                        "./default/bootstrap_script.rb",
                        {}, 
                        {
                          :block_stack => [],
                          :yield_block_stack => [],
                        }]]

    #ラベル関連（未検証）
    @label_name = options[:label_name] || nil
    @label_id = options[:label_id] || 0
    @label_options = options[:label_options] || nil

    #カーソル歌詞設定
    @cursor_visible = true
    @cursor_type = IDC_ARROW

    super(nil, 
          options, 
          { :block_stack => []}, 
          @root_control)
  end
=begin
  def serialize(options = {})

    options.update({
      :label_name => @label_name,
      :label_id => @label_id,
      :label_options => @label_options,
    })

    return super(options)
  end
=end
  def update
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

  def render(offset_x, offset_y, target, 
              parent = {:width => Window.width, 
                        :height => Window.width, 
                        :mouse_pos_x => Input.mouse_x,
                        :mouse_pos_y => Input.mouse_y})
    super
  end
end

class Tsukasa < RenderTargetControl
  def command__RESIZE_(argument, options, inner_options)
    Window.resize(options[:width], 
                  options[:height])
    self.width = options[:width]
    self.height = options[:height]
  end

  #スクリーンショットキャプチャ
  def command__CAPTURE_SS_(argument, options, inner_options)
    Window.get_screen_shot(argument,options[:format] || FORMAT_PNG)
  end

  #フルスクリーンのオンオフ
  def command__FULL_SCREEN_(argument, options, inner_options)
    Window.full_screen = argument #bool
  end

  #アプリを起動してからのミリ秒を取得する
  def command__RUNNING_TIME_(argument, options, inner_options)
    eval_block( Window.running_time, 
                options, 
                inner_options[:block_stack].dup, 
                inner_options[:yield_block_stack].dup, 
                &inner_options[:block])
  end

  #フルスクリーン化可能な解像度のリストを取得する
  def command__SCREEN_MODES_(argument, options, inner_options)
    eval_block( Window.get_screen_modes, 
                options, 
                inner_options[:block_stack].dup, 
                inner_options[:yield_block_stack].dup, 
                &inner_options[:block])
  end

  def command_label(argument, options, inner_options)
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
end
