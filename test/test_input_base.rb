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

class TestInputBase < Minitest::Test
#ユーザー入力をともなうテストのため、一時的にコメントアウト中
=begin
  #ゲーム側で判定タイミングのトリガーを用意するテスト
  def test_2017_01_09_1_キー入力確認
    puts "zキーを押してください"
    #コントロールの生成
    control = Tsukasa::Control.new() do
      #動的プロパティの追加
      _DEFINE_PROPERTY_ test: nil
      #無限ループ
      _LOOP_ do
        _CREATE_ :Input, id: :input
        #zキーが押された場合
        _CHECK_ [:_ROOT_, :input], equal:{ key_down: Tsukasa::K_Z} do
          #プロパティに値を設定
          _SET_ test: Tsukasa::K_Z
          #メインループを終了する
          _EXIT_
        end
        #１フレ送る
        _END_FRAME_
      end
    end

    #メインループ
    DXRuby::Window.loop() do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0) #処理
      control.render(0, 0, DXRuby::Window) #描画
      break if control.exit #メインループ終了判定
    end

    #テスト
    assert_equal(control.test, Tsukasa::K_Z)
  end

=end
end
