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

###############################################################################
#システムサポート
###############################################################################

#コマンド名のalias
_DEFINE_ :backlay do
  render_to_image
end

#_SET_の第１引数を送信先コントロールにした物
#TODO：これ、ネストsetと競合してるので再検討
_DEFINE_ :set do |options|
  _SEND_ options[:_ARGUMENT_], interrupt: true do
    options.delete(:_ARGUMENT_)
    _SET_ options
  end
end

#汎用_DELETE_
_DEFINE_ :delete do |options|
  _SEND_ options[:_ARGUMENT_], interrupt: true do
    _DELETE_
  end
end

#無名関数として機能する
_DEFINE_ :scope do |options|
  _YIELD_ options
end

#無名関数として機能する（_BREAK_で脱出できる）
#TODO：もうちょっと上手い方法はないものか
_DEFINE_ :about do |options|
  _YIELD_ options
  _END_SCOPE_
end

#指定フレーム数ウェイト
#ex. wait_count 60
_DEFINE_ :wait_count do |options|
  _WAIT_ [:count], count: options[:_ARGUMENT_]
end

#指定コマンドウェイト
#ex. wait_command :move
_DEFINE_ :wait_command do |options|
  _WAIT_ [:command], command: options[:_ARGUMENT_]
end

#可視設定
_DEFINE_ :visible do |options|
  set options
end

#単機能キー入力待ち
_DEFINE_ :wait_push do
  _WAIT_ [:key_push]
  _END_FRAME_
end

###############################################################################
#テキストレイヤ関連
###############################################################################

#_TEXT_デフォルト送信
_DEFINE_ :text do |options|
  _SEND_ default: :TextPageControl do
    _TEXT_ options[:_ARGUMENT_]
  end
end

#_line_feed_デフォルト送信
_DEFINE_ :line_feed do
  _SEND_ default: :TextPageControl  do
    _LINE_FEED_
  end
end

#_flush_デフォルト送信
_DEFINE_ :flush do
  _SEND_ default: :TextPageControl  do
    _FLUSH_
  end
end

#_rubi_デフォルト送信
_DEFINE_ :rubi do |options|
  _SEND_ default: :TextPageControl do
    _RUBI_ options[:_ARGUMENT_], text: options[:text]
  end
end

#標準ポーズコマンド
_DEFINE_ :pause do |options|
  #■行表示中スキップ処理
  _SEND_ :default_text_page_control0 do 
    #idleあるいはキー入力待機
    _WAIT_ [:key_push, :idle, :mode], mode: :ctrl_skip

    if options[:icon]
      _SEND_ :last do
        _CALL_ options[:icon], id: :icon
      end
    end

    _CHECK_ [:key_push] do
      #スキップフラグを立てる
      _SET_ :_MODE_STATUS_, skip: true
    end

    #キー入力伝搬を止める為に１フレ送る
    _END_FRAME_ 

    #■行末待機処理

    #キー入力待機
    _WAIT_ [:key_push, :mode], mode: :ctrl_skip

    #アイコン削除
    delete :icon

    #ウェイクに移行
    _SET_ :_MODE_STATUS_, wake: true

    #スキップフラグを下ろす
    _SET_ :_MODE_STATUS_, skip: false

    #CTRLスキップの為に必要
    _END_FRAME_ 
  end

  #■ルートの待機処理
  #スリープモードを設定
  _SET_ :_MODE_STATUS_, wake: false

  _SET_ :_MODE_STATUS_, ctrl_skip: false
  _CHECK_ [:key_down] , key_code: K_RCONTROL , keep: true do
    _SET_ :_MODE_STATUS_, ctrl_skip: true
  end

  #ウェイク待ち
  _WAIT_ [:mode], mode: [:ctrl_skip, :wake]
end

#行クリック待ちポーズ
_DEFINE_ :line_pause do
  pause icon: :line_icon_func
end

#行クリック待ちポーズ(line_pauseの省略板)
_DEFINE_ :lp do
  line_pause
end

#ページクリック待ちポーズ
_DEFINE_ :page_pause do
  pause icon: :page_icon_func
  flush
end

###############################################################################
#デフォルトのレイヤ群
###############################################################################

#標準テキストウィンドウ
_DEFINE_ :TextWindow do |options|
  _CREATE_ :LayoutControl,
    x_pos: options[:x_pos],
    y_pos: options[:y_pos],
    width: options[:width],
    height: options[:height],
    index: 1000000, #描画順序
    id: options[:id] do
      #デフォルトの背景画像
      _CREATE_ :ImageControl, id: :bg
      ##このコントロールにload_imageを実行すると背景画像をセットできる。
      ##ex.
      ##  _SEND_ :message0 do
      ##    _SEND_ :bg do
      ##      load_image  file_path: "./sozai/bg_test.jpg" 
      ##    end
      ##  end

      #メッセージウィンドウ
      _CREATE_ :TextPageControl, 
        x_pos: 0,
        y_pos: 0,
        width: options[:width],
        id: options[:text_page_id],
        size: 32, 
        fontname: "ＭＳＰ ゴシック",
        wait_frame: 2,
        char_renderer: Proc.new{
          transition_fade frame: 15,
            count: 0,
            start: 0,
            last: 255
          #CTRLスキップチェック
          _CHECK_ [:mode], mode: :ctrl_skip, keep: true do
            _SET_ :draw_option, alpha: 255
            _SET_ :_MODE_STATUS_, wake: true
          end
          _WAIT_ [:command, :mode], command: :transition_fade ,mode: [:wake, :ctrl_skip] do
            _SEND_ nil, interrupt: true do
              set idle_mode: false
            end
          end
          _SET_ :_MODE_STATUS_, wake: false
          _WAIT_ [:mode], mode: :wake
          _SET_ :_MODE_STATUS_, skip: false
          transition_fade frame: 60,
            count: 0,
            start: 255,
            last:128
          _WAIT_ [:command, :mode], command: :transition_fade ,mode: [:wake, :ctrl_skip] 
        } do
        set size: 32
        _FLUSH_ #これが必ず必要
        #右ＣＴＲＬによるテキストスキップ
        _SET_ :_MODE_STATUS_, ctrl_skip: false
        _CHECK_ [:key_down] , key_code: K_RCONTROL, keep: true do
          _SET_ :_MODE_STATUS_, ctrl_skip: true
        end
      end
  end
end

TextWindow id: :message0, text_page_id: :default_text_page_control0,
  x_pos: 128,
  y_pos: 256 + 192,
  width: 1024,
  height: 192

=begin
#全画面の場合
TextWindow id: :message0, text_page_id: :default_text_page_control0,
  x_pos: 64,
  y_pos: 64,
  width: 1024,
  height: 768
=end

_DEFINE_ :line_icon_func do |options|
  _CREATE_ :LayoutControl, 
          :x_pos => 0, 
          :y_pos => 0, 
          :width => 24,
          :height => 24,
          :align_y => :bottom,
          :float_mode => :right,
          :id => options[:id],
          :float_mode => :right do
    _CREATE_ :TileImageControl, 
            :tiles => true,
            :file_path=>"./sozai/icon/icon_8_a.png", 
            :id=>:test, 
            :x_count => 4, 
            :y_count => 2 
  end
end

_DEFINE_ :page_icon_func do |options|

  _CREATE_ :LayoutControl, 
          :x_pos => 0, 
          :y_pos => 0, 
          :width => 24,
          :height => 24,
          :align_y => :bottom,
          :float_mode => :right,
          :id => options[:id],
          :float_mode => :right do
    _CREATE_ :TileImageControl, 
            :tiles => true, 
            :file_path=>"./sozai/icon/icon_4_a.png", 
            :id=>:test, 
            :x_count => 4, 
            :y_count => 1 do
      _WHILE_ [:true] do
        set 3, visible: false
        set 0, visible: true
      	_WAIT_ [:count], count: 5
        set 0, visible: false
        set 1, visible: true
      	_WAIT_ [:count], count: 5
        set 1, visible: false
        set 2, visible: true
      	_WAIT_ [:count], count: 5
        set 2, visible: false
        set 3, visible: true
      	_WAIT_ [:count], count: 5
      end
    end
  end
end

#初期レイヤ（背景）
_CREATE_ :ImageControl,
  index: 0, #描画順序
  id: :base do
end

#初期レイヤ０
_CREATE_ :ImageControl,
  index: 1000, #描画順序
  id: 0 do
end

#初期レイヤ１
_CREATE_ :ImageControl,
  index: 2000, #描画順序
  id: 1 do
end

#初期レイヤ２
_CREATE_ :ImageControl,
  index: 3000, #描画順序
  id: 2 do
end

###############################################################################
#汎用コントロール
###############################################################################

#ボタンコントロール
_DEFINE_ :button do |options|
  _CREATE_ :LayoutControl, 
          :x_pos => options[:x_pos] || 0,
          :y_pos => options[:y_pos] || 0,
          :width => 256,
          :height => 256,
          :id=>options[:id] do
    _CREATE_ :ImageControl, 
      :file_path=>"./sozai/button_normal.png", 
      :id=>:normal
    _CREATE_ :ImageControl, 
      :file_path=>"./sozai/button_over.png", 
      :id=>:over, :visible => false
    _CREATE_ :ImageControl, 
      :file_path=>"./sozai/button_key_down.png", 
      :id=>:key_down, :visible => false
    on_mouse_over do
      set :normal, visible: false
      set :over,   visible: true
      set :key_down, visible: false
    end
    on_mouse_out do
      set :over,   visible: false
      set :normal, visible: true
      set :key_down, visible: false
    end
    on_key_down do
      set :over,   visible: false
      set :normal, visible: false
      set :key_down, visible: true
    end
    on_key_up do
      set :key_down, visible: false
      set :normal, visible: false
      set :over,   visible: true
    end
    _YIELD_
  end
end

