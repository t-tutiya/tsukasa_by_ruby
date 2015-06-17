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
    wait [:keypush, :idol]
    
    #キー入力伝搬を止める為に１フレ送る
    next_frame 

    #■行末待機処理

    #キー入力があるまで待機
    check_key_push
    
    _YIELD_
    
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
  wait [:wake]
end
