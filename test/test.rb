#! ruby -E utf-8

require 'minitest/test'
require '../system/Tsukasa.rb'

#このコードが動作する為には、testフォルダ配下にAyame.dllが配置されている必要がある（将来的に依存関係を辞めたいが、解消できるのか不明）

MiniTest.autorun

class TC_Foo < Minitest::Test
  def test_foo
    tsukasa = Tsukasa::Window.new({ :width => 640,
                                    :height => 480,
                                    })

    DXRuby::Window.loop() do
      #ここでテストを行う想定
      #司エンジン処理
      tsukasa.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
      tsukasa.render(0, 0, DXRuby::Window)

      #スクリプトで終了コマンドが実行された場合
      break if tsukasa.close?
    end
  end

  def test_bar
    tsukasa = Tsukasa::Window.new({ :width => 640,
                                    :height => 480,
                                    })

    DXRuby::Window.loop() do
      #ここでテストを行う想定
      #司エンジン処理
      tsukasa.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
      tsukasa.render(0, 0, DXRuby::Window)

      #スクリプトで終了コマンドが実行された場合
      break if tsukasa.close?
    end
  end
end
