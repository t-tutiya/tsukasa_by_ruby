require 'spec_helper'
require 'dxruby'
require './system/Tsukasa.rb'

RSpec.describe Tsukasa::Control do

  it '2017_02_08_1_キー入力確認' do
    #DXRuby::Input.key_down?(Tsukasa::K_Z)にスタブを設定
    allow(DXRuby::Input).to receive(:key_down?).with(Tsukasa::K_Z).and_return(true)

    #コントロールの生成
    control = Tsukasa::Control.new() do
      #動的プロパティの追加
      _DEFINE_PROPERTY_ test: nil
      #無限ループ
      _LOOP_ do
        #Inputオブジェクトをモックのクラスを指定して生成
        _CREATE_ :Input, id: :input
        #zキーが押された場合
        _CHECK_ [:_ROOT_, :input], key_down: Tsukasa::K_Z do
          #プロパティに値を設定
          _SET_ test: Tsukasa::K_Z
          #メインループを終了する
          _EXIT_
        end
        #１フレ送る
        _HALT_
      end
    end
    #メインループ
    DXRuby::Window.loop() do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y) #処理
      control.render(0, 0, DXRuby::Window) #描画
      break if control.exit #メインループ終了判定
    end

    #テスト
    expect(control.test).to eq(Tsukasa::K_Z)
  end
end
