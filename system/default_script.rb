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

#標準ポーズコマンド
define :pause do
  #■行表示中スキップ処理
  about :default_char_container do
    #idleあるいはキー入力待機
    wait [:key_push, :idol]

    line_icon
    
    check_key_push do
      #スキップフラグを立てる
      set :root, skip_mode: true , all: true, interrupt: true
    end

    #キー入力伝搬を止める為に１フレ送る
    end_frame 

    #■行末待機処理

    #キー入力待機
    wait [:key_push]

    delete :page_icon_test, interrupt: true

    #ルートにウェイクを送る
    set :root, sleep_mode: :wake , all: true, interrupt: true

    #スキップフラグを下ろす
    set :root, skip_mode: false , all: true, interrupt: true

    #スキップフラグ伝搬が正しく行われるように１フレ送る
    end_frame
  end

  #■ルートの待機処理
  #スリープモードを設定
  sleep_mode :sleep
  #ウェイク待ち
  wait [:wake] do
    _YIELD_
  end
end

#指定フレーム数ウェイト
#ex. wait_count 60
define :wait_count do |options|
  wait [:count], count: options[:wait_count]
end

#指定コマンドウェイト
#ex. wait_command :move_line
define :wait_command do |options|
  wait [:command], command: options[:wait_command]
end

#スキップモードの設定
define :skip_mode do |options|
  set options
end

define :sleep_mode do |options|
  set options
end


#可視設定
define :visible do |options|
  set options
end

#単機能キー入力待ち
define :wait_push do
  wait [:key_push]
  end_frame
end

define :image do |options|
  create :ImageControl , options do
    _YIELD_
  end
end

#標準テキストウィンドウ
#TODOデバッグ用なので各種数字は暫定
create :RenderTargetContainer,
  x_pos: 128,
  y_pos: 528,
  width: 1024,
  height: 600,
  index: 1000000, #描画順序
  id: :main_text_layer do
    #メッセージウィンドウ
    create :TextPageControl, 
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
        wait [:command, :skip], command: :transition_fade do
          #pp "idle"
          set idle_mode: false, interrupt: true
        end
        sleep_mode :sleep
        wait [:wake]
        skip_mode false
        transition_fade frame: 60,
          count: 0,
          start: 255,
          last:128
        wait [:command, :skip], command: :transition_fade
      } do
      set font_config: {size: 32}
    end
  end


define :page_icon do |options|

  create :LayoutControl, 
          :x_pos => 0, 
          :y_pos => 0, 
          :width => 24,
          :height => 24,
          :id => :page_icon_test,
          :float_mode => :right do
    create :ImageTilesContainer, 
            :file_path=>"./sozai/icon_8_a.png", 
            :id=>:test, 
            :x_count => 4, 
            :y_count => 2
    _WHILE_ ->{true} do
      set 7, visible: false
      set 0, visible: true
    	wait [:count], count: 5
      set 0, visible: false
      set 1, visible: true
    	wait [:count], count: 5
      set 1, visible: false
      set 2, visible: true
    	wait [:count], count: 5
      set 2, visible: false
      set 3, visible: true
    	wait [:count], count: 5
      set 3, visible: false
      set 4, visible: true
    	wait [:count], count: 5
      set 4, visible: false
      set 5, visible: true
    	wait [:count], count: 5
      set 5, visible: false
      set 6, visible: true
    	wait [:count], count: 5
      set 6, visible: false
      set 7, visible: true
    	wait [:count], count: 30
    end
  end
end

