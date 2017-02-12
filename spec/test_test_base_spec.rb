require 'spec_helper'
require 'dxruby'
require './system/Tsukasa.rb'

RSpec.describe Tsukasa::Control do

  it 'コントロールのダンプとの比較によるテスト' do
    #コントロールの生成
    control = Tsukasa::Control.new() do
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
