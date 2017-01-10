#! ruby -E utf-8
require 'pp'
require 'minitest/test'
require './system/Tsukasa.rb'

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

class TC_Image_base < Minitest::Test

  #ゲーム側で判定タイミングのトリガーを用意するテスト
  def test_2017_01_09_1_描画コマンド動作確認
    #コントロールの生成
    control = Tsukasa::Window.new() do
      _CREATE_ :Image, width: 256, height:256 do
        _LINE_ x1:0, y1:0, x2: 256, y2:256, color:[255,255,255]
        _BOX_ x1:128, y1:0, x2: 256, y2:128, color:[255,255,255]
        _BOX_ x1:0, y1:128, x2: 128, y2:256, color:[255,255,255], fill: true
        _CIRCLE_ x: 64, y: 64 , r:62, color:[255,0,0]
        _CIRCLE_ x: 64 + 128, y: 64 + 128 , r:64, color:[255,0,0], fill: true
        _TRIANGLE_ x1:32, y1:32, x2: 64, y2:64, x3:32, y3:64, color:[0,0,255]
        _TRIANGLE_ x1:64, y1:64, x2: 96, y2:96, x3:64, y3:96, color:[0,0,255], fill: true
      end
      _END_FRAME_
      _EXIT_
    end

    #メインループ
    DXRuby::Window.loop() do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0) #処理
      control.render(0, 0, DXRuby::Window) #描画
      break if control.exit #メインループ終了判定
    end

  end

  #ゲーム側で判定タイミングのトリガーを用意するテスト
  def test_2017_01_09_2_ブロック呼び出し系コマンド確認
    #コントロールの生成
    control = Tsukasa::Window.new() do
      _CREATE_ :Image, width: 256, height:256 do
        _PIXEL_ x:128, y:128, color:[255,255,255]
        _PIXEL_ x:128, y:128 do |color:|
          _PUTS_ color
        end
        _COMPARE_ x:128, y:128, color:[255,255,255] do
          _PUTS_ "OK"
        end
      end
      _END_FRAME_
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
