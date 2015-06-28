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
  about :default_text_layer do
    #idleになるかキー入力を待つ
    #※wait中にキーが押された場合、waitはスキップモードフラグを立てる
    wait [:key_push, :idol]
    
    #キー入力伝搬を止める為に１フレ送る
    #現仕様では不要なので試験的にコメントアウト
    #next_frame 

    #■行末待機処理

    #キー入力があるまで待機
    check_key_push

    wait [:idol]

    #■ポーズ終了処理

    #ルートにウェイクを送る
    #TODO：本来rootにのみ通知できれば良い筈
    sleep_mode_all :wake
    #スキップフラグを下ろす
    skip_mode_all false
    #スキップフラグ伝搬が正しく行われるように１フレ送る
    next_frame
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

#標準テキストウィンドウ
#TODOデバッグ用なので各種数字は暫定
create :LayoutContainer,
  x_pos: 128,
  y_pos: 528,
  width: 1024,
  height: 600,
  index: 1000000, #描画順序
  id: :main_text_layer do
    #メッセージウィンドウ
    create :CharContainer, 
      x_pos: 2,
      y_pos: 2,
      id: :default_text_layer,
      font_config: { :size => 32, 
                     :face => "ＭＳＰ ゴシック"},
      style_config: { :wait_frame => 2,} do
      char_renderer do
        transition_fade_with_skip frame: 15,
          count: 0,
          start: 0,
          last: 255
        wait [:command, :skip], command: :transition_fade_with_skip
        sleep_mode :sleep
        wait [:wake]
        skip_mode false
        transition_fade_with_skip frame: 60,
          count: 0,
          start: 255,
          last:128
        wait [:command, :skip], command: :transition_fade_with_skip
      end
    end
  end
