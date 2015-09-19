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

#_TEXT_デフォルト送信
_DEFINE_ :text_style do |options|
  _SEND_ default: :TextPageControl do
    _SET_ options
  end
end

#標準ポーズコマンド
_DEFINE_ :pause do |options|
  _SEND_ :default_text_page_control0 do 
    #クリック待ちアイコンの表示
    _SEND_ :last do
      _END_FRAME_

      _WAIT_ [:count], count: 15

      _CALL_ options[:icon], id: :icon do
        #スペースキーあるいはCTRLキーの押下待機
        _WAIT_ [:key_push, :key_down] , 
                key_down_code: K_RCONTROL

        #クリック待ちアイコンの削除
        _SEND_ :icon do
          _DELETE_
        end

        #ウェイクに移行
        _SET_ sleep: false
      end
    end
  end

  #■ルートの待機処理
  #スリープ状態に移行
  _SET_ sleep: true

  #ウェイク状態まで待機
  _WAIT_ [:not_sleep, :key_down], 
          key_down_code: K_RCONTROL do
    _YIELD_
  end

  #１フレ分は必ず表示させる
  _END_FRAME_ 
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

_DEFINE_ :text0 do
  _SEND_ default: :TextPageControl, interrupt: true do
    _YIELD_
  end
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
    draw_option: {z: 1000000}, #描画順序
    id: options[:id] do
      #デフォルトの背景画像
      _CREATE_ :ImageControl, id: :bg
      ##このコントロールにload_imageを実行すると背景画像をセットできる。
      ##ex.
      ##  _SEND_ :message0 do
      ##    _SEND_ :bg do
      ##      _SET_ file_path: "./sozai/bg_test.jpg" 
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
        wait_frame: 2 do
          _CHAR_RENDERER_ do
            #フェードイン（スペースキーか右CTRLが押されたらスキップ）
            transition_fade total_frame: 15,
                            start: 0,
                            last: 255,
                            check: [[:key_push, :key_down], 
                                    {:key_down_code => K_RCONTROL}] do
                              _SET_ :draw_option, alpha: 255
                            end
            #トランジションが終了するまで非アイドル状態
            _WAIT_  [:command], command: :transition_fade
            #スリープ状態に移行
            _SET_ sleep: true
            #ウェイク状態になるまで待機
            _WAIT_ [:not_sleep]
            #キー入力伝搬を防ぐ為に１フレ送る
            _END_FRAME_
            #ハーフフェードアウト（スペースキーか右CTRLが押されたらスキップ）
            transition_fade total_frame: 60,
                            last:128,
                            check: [[:key_push ,:key_down], 
                                    {:key_down_code => K_RCONTROL}] do
                              #スキップされた場合
                              _CHECK_ :key_down, key_down_code: K_RCONTROL do
                                #CTRLスキップ中であれば透明度255
                                _SET_ :draw_option, alpha: 255
                              end
                              _CHECK_ :key_push do
                                #CTRLスキップ中でなければ透明度128
                                _SET_ :draw_option, alpha: 128
                              end
            end
            #トランジションが終了するまで待機
            _WAIT_ [:command], command: :transition_fade
          end
          _SET_ size: 32
          _FLUSH_ #これが必ず必要
      end
  end
end

TextWindow id: :text0, text_page_id: :default_text_page_control0,
  x_pos: 128,
  y_pos: 256 + 192,
  width: 1024,
  height: 192

=begin
#全画面の場合
TextWindow id: :text1, text_page_id: :default_text_page_control0,
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
          :id => options[:id] do
    _CREATE_ :TileImageControl, 
            :tiles => true,
            :file_path=>"./sozai/icon/icon_8_a.png", 
            :script_file_path=>"./sozai/icon/icon_8_a.rb", 
            :id=>:test, 
            :x_count => 4, 
            :y_count => 2 
    _YIELD_
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
          :id => options[:id] do
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
    _YIELD_
  end
end

#初期レイヤ（背景）
_CREATE_ :ImageControl,
  draw_option: {z: 0}, #描画順序
  id: :base do
end

#初期レイヤ０
_CREATE_ :ImageControl,
  draw_option: {z: 1000}, #描画順序
  id: 0 do
end

#初期レイヤ１
_CREATE_ :ImageControl,
  draw_option: {z: 2000}, #描画順序
  id: 1 do
end

#初期レイヤ２
_CREATE_ :ImageControl,
  draw_option: {z: 3000}, #描画順序
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

