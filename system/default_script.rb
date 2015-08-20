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

_DEFINE_ :set do |options|
  _SEND_ options[:_ARGUMENT_], interrupt: true do
    options.delete(:_ARGUMENT_)
    _SET_ options
  end
end

_DEFINE_ :delete do |options|
  _SEND_ options[:_ARGUMENT_], interrupt: true do
    _DELETE_
  end
end


_DEFINE_ :text do |options|
  _SEND_ :default_char_container do
    _TEXT_ options[:_ARGUMENT_]
  end
end

_DEFINE_ :line_feed do
  _SEND_ :default_char_container do
    _LINE_FEED_
  end
end

_DEFINE_ :flush do
  _SEND_ :default_char_container do
    _FLUSH_
  end
end

#無面関数として機能する
_DEFINE_ :scope do |options|
  _YIELD_ options
end

#無面関数として機能する
_DEFINE_ :about do |options|
  _YIELD_ options
  _END_SCOPE_
end

#標準ポーズコマンド
_DEFINE_ :pause do |options|
  #■行表示中スキップ処理
  _SEND_ :default_char_container do 
    #idleあるいはキー入力待機
    _WAIT_ [:key_push, :idle]

    if options[:icon]
      _SEND_ :last do
        _CALL_ options[:icon], id: :icon
      end
    end

    _CHECK_ [:key_push] do
      #スキップフラグを立てる
      _SEND_ :all , interrupt: true do
        _SET_ skip_mode: true
      end
    end

    #キー入力伝搬を止める為に１フレ送る
    end_frame 

    #■行末待機処理

    #キー入力待機
    _WAIT_ [:key_push]

    #アイコン削除
    delete :icon

    #ルートにウェイクを送る
    _SEND_ :all , root: true, interrupt: true do
      _SET_ sleep_mode: :wake
    end

    #スキップフラグを下ろす
    _SEND_ :all , root: true, interrupt: true do
      _SET_ skip_mode: false
    end

  end

  #■ルートの待機処理
  #スリープモードを設定
  sleep_mode mode: :sleep
  #ウェイク待ち
  _WAIT_ [:wake]
end

#指定フレーム数ウェイト
#ex. wait_count 60
_DEFINE_ :wait_count do |options|
  _WAIT_ [:count], count: options[:_ARGUMENT_]
end

#指定コマンドウェイト
#ex. wait_command :move_line
_DEFINE_ :wait_command do |options|
  _WAIT_ [:command], command: options[:_ARGUMENT_]
end

#スキップモードの設定
_DEFINE_ :skip_mode do |options|
  set skip_mode: options[:mode]
end

_DEFINE_ :sleep_mode do |options|
  set sleep_mode: options[:mode]
end


#可視設定
_DEFINE_ :visible do |options|
  set options
end

#単機能キー入力待ち
_DEFINE_ :wait_push do
  _WAIT_ [:key_push]
  end_frame
end

_DEFINE_ :image do |options|
  _CREATE_ :ImageControl , options do
    _YIELD_
  end
end

#標準テキストウィンドウ
#TODOデバッグ用なので各種数字は暫定
_CREATE_ :LayoutControl,
  x_pos: 128,
  y_pos: 528,
  width: 1024,
  height: 600,
  index: 1000000, #描画順序
  id: :main_text_layer do
    #メッセージウィンドウ
    _CREATE_ :TextPageControl, 
      x_pos: 2,
      y_pos: 2,
      id: :default_char_container,
      font_config: { :size => 32, 
                     :fontname => "ＭＳＰ ゴシック"},
      style_config: { :wait_frame => 2,},
      char_renderer: Proc.new{
        transition_fade frame: 15,
          count: 0,
          start: 0,
          last: 255
        _WAIT_ [:command, :skip], command: :transition_fade do
          #pp "idle"
          _SEND_ nil, interrupt: true do
            set idle_mode: false
          end
        end
        set sleep_mode: :sleep
#        sleep_mode mode: :sleep
        _WAIT_ [:wake]
        skip_mode mode: false
        transition_fade frame: 60,
          count: 0,
          start: 255,
          last:128
        _WAIT_ [:command, :skip], command: :transition_fade
      } do
      set font_config: {size: 32}
    end
  end


_DEFINE_ :line_icon_func do |options|
  _CREATE_ :LayoutControl, 
          :x_pos => 0, 
          :y_pos => 0, 
          :width => 24,
          :height => 24,
          :id => options[:id],
          :float_mode => :right do
    _CREATE_ :ImageControl, 
            :tiles => true,
            :file_path=>"./sozai/icon_8_a.png", 
            :id=>:test, 
            :x_count => 4, 
            :y_count => 2
    _WHILE_ [:true] do
      set 7, visible: false
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
      set 3, visible: false
      set 4, visible: true
    	_WAIT_ [:count], count: 5
      set 4, visible: false
      set 5, visible: true
    	_WAIT_ [:count], count: 5
      set 5, visible: false
      set 6, visible: true
    	_WAIT_ [:count], count: 5
      set 6, visible: false
      set 7, visible: true
    	_WAIT_ [:count], count: 30
    end
  end
end

_DEFINE_ :page_icon_func do |options|

  _CREATE_ :LayoutControl, 
          :x_pos => 0, 
          :y_pos => 0, 
          :width => 24,
          :height => 24,
          :id => options[:id],
          :float_mode => :right do
    _CREATE_ :ImageControl, 
            :tiles => true, 
            :file_path=>"./sozai/icon_4_a.png", 
            :id=>:test, 
            :x_count => 4, 
            :y_count => 1
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
