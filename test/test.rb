#! ruby -E utf-8
require 'pp'
require 'minitest/test'
require '../system/Tsukasa.rb'

#このコードが動作する為には、testフォルダ配下にAyame.dllが配置されている必要がある（将来的に依存関係を辞めたいが、解消できるのか不明）

MiniTest.autorun

class TC_Foo < Minitest::Test
  def test_foo
    tsukasa = Tsukasa::Control.new() do
      _PUTS_ "test_foo"
      _EXIT_
    end

    DXRuby::Window.loop() do
      tsukasa.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
      tsukasa.render(0, 0, DXRuby::Window)
      break if tsukasa.exit
    end
    
    reslut = [[:_SET_,
                {:id=>:"Tsukasa::Control",
                 :child_update=>true,
                 :script_parser=>{},
                 :exit=>true},
                {}]]
    assert_equal(tsukasa.serialize(), reslut, "NO")
  end
end
