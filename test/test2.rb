#! ruby -E utf-8
require 'pp'
require 'minitest/test'
require '../system/Tsukasa.rb'

#このコードが動作する為には、testフォルダ配下にAyame.dllが配置されている必要がある（将来的に依存関係を辞めたいが、解消できるのか不明）

MiniTest.autorun

class TC_Foo < Minitest::Test

  #コントロールのダンプとの比較によるテスト
  def test_1
    #コントロールの生成
    control = Tsukasa::Control.new() do
      #メインループを終了する
      _EXIT_
    end

    #メインループ
    DXRuby::Window.loop() do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0) #処理
      control.render(0, 0, DXRuby::Window) #描画
      break if control.exit #メインループ終了判定
    end
    
    reslut = [[:_SET_,
                {:id=>:"Tsukasa::Control",
                 :child_update=>true,
                 :script_parser=>{},
                 :exit=>true},
                {}]]

    #テスト
    assert_equal(control.serialize(), reslut)
  end
end
