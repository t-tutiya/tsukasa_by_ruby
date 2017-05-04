require 'spec_helper'
require 'dxruby'
require './system/Tsukasa.rb'

###############################################################################
#TSUKASA for DXRuby ver2.2(2017/2/14)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2017> <tsukasa TSUCHIYA>
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


RSpec.describe Tsukasa::Collisionable do

  it '2017_05_04_1_衝突判定テスト' do
    #コントロールの生成
    control = Tsukasa::Window.new() do
      #動的プロパティの追加
      _DEFINE_PROPERTY_ test: 0

      _CREATE_ :CollisionableLayout, id: :col0, 
        y: 1, angle: 45, shape: [0,0,64,64] do
        _CREATE_ :Image,  
          width: 64, height: 64, color:[0,255,255],angle: 45, 
          center_x: 0, center_y: 0
        _MOVE_ 128, x:[0,256] do
          _CHECK_ not_collision_target: [:_ROOT_, :col1] do
            _SEND_ [0] do
              _FILL_ [0,255,255]
            end
          end
          _CHECK_ collision_target: [:_ROOT_, :col1] do
            _SEND_ [0] do
              _FILL_ [255,0,0]
            end
          end
        end
        _EXIT_
      end

      _CREATE_ :CollisionableLayout, id: :col1, 
        y:1, x: 64+16, shape: [0,0,64,64]  do
        _CREATE_ :Image,  width: 64, height: 64, color:[255,255,255]
      end
    end
    #メインループ
    DXRuby::Window.loop() do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y) #処理
      control.render(0, 0, DXRuby::Window) #描画
      break if control.exit #メインループ終了判定
    end

    #テスト
  end

end
