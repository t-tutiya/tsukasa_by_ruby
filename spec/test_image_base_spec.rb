require 'spec_helper'
require 'dxruby'
require './system/Tsukasa.rb'

RSpec.describe Tsukasa::Control do

  it '2017_01_09_1_描画コマンド動作確認' do
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
      _HALT_
      _EXIT_
    end
    #メインループ
    DXRuby::Window.loop() do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y) #処理
      control.render(0, 0, DXRuby::Window) #描画
      break if control.exit #メインループ終了判定
    end

    #テスト
  end

  #ゲーム側で判定タイミングのトリガーを用意するテスト
  it '2017_01_09_2_ブロック呼び出し系コマンド確認' do
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
      _HALT_
      _EXIT_
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
