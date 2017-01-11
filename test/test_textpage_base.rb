#! ruby -E utf-8
require 'pp'
require 'minitest/test'
require './system/Tsukasa.rb'
#文字描画
require './system/Char.rb'
#テキストページ管理
require './system/TextPage.rb'

###############################################################################
#TSUKASA for DXRuby ver2.1(2016/12/23)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2016> <tsukasa TSUCHIYA>
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

MiniTest.autorun


class TestTextPageBase < Minitest::Test

  def test_2017_1_1_1_テキスト表示テスト
    #コントロールの生成
    control = Tsukasa::TextPage.new({}, nil,nil,nil) do
      _TEXT_ "テキストウィンドウテスト表示１"
      _LINE_FEED_
      _TEXT_ "テキストウィンドウテスト表示１"
      _LINE_FEED_
      _TEXT_ "テキストウィンドウテスト表示１"
      _LINE_FEED_
      _END_FRAME_
      _FLUSH_
      _TEXT_ "テキストウィンドウテスト表示２"
      _LINE_FEED_
      _TEXT_ "テキストウィンドウテスト表示２"
      _LINE_FEED_
      _TEXT_ "テキストウィンドウテスト表示２"
      _LINE_FEED_
      _LOOP_ 60 do
        _END_FRAME_
      end
      #メインループを終了する
      _EXIT_
    end

    #メインループ
    DXRuby::Window.loop() do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0) #処理
      control.render(0, 0, DXRuby::Window) #描画
      break if control.exit #メインループ終了判定
    end
  end
end