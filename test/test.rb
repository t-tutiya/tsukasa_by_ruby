#! ruby -E utf-8
require 'pp'
require 'minitest/test'
require '../system/Tsukasa.rb'

#このコードが動作する為には、testフォルダ配下にAyame.dllが配置されている必要がある（将来的に依存関係を辞めたいが、解消できるのか不明）

MiniTest.autorun

class TC_Foo < Minitest::Test

  #通常ループ
  def test_1
    tsukasa = Tsukasa::Control.new() do
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

  #通常ループ
  def test_1_2
    tsukasa = Tsukasa::Control.new() do
      _DEFINE_PROPERTY_ test: 3
      _MOVE_ 30, test:[40,400]
      _EXIT_
    end

    DXRuby::Window.loop() do
      tsukasa.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
      tsukasa.render(0, 0, DXRuby::Window)
      break if tsukasa.exit
    end
    
    reslut = [[:_SET_,
                {:id=>:"Tsukasa::Control",
                 :test=>400,
                 :child_update=>true,
                 :script_parser=>{},
                 :exit=>true},
                {}]]
                 
    assert_equal(tsukasa.serialize()[0][1][:test], 400, "NO")
  end

  #通常ループ
  def test_1_3
    tsukasa = Tsukasa::Control.new() do
      _DEFINE_PROPERTY_ test: 3
      _MOVE_ 50, test:[0,100]
      _EXIT_
    end

    DXRuby::Window.loop() do
      tsukasa.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
      tsukasa.render(0, 0, DXRuby::Window)
      break if tsukasa.exit
    end
    
    assert_equal(tsukasa.test, 100, "NO")
  end

  #通常ループ
  def test_1_4
    tsukasa = Tsukasa::Control.new() do
      _DEFINE_PROPERTY_ test: 3
      _MOVE_ 50, test:[0,100]
      _EXIT_
    end

    #２５フレーム回したと想定
    25.times do
      tsukasa.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
    end

    assert_equal(tsukasa.test, 50, "NO")
  end


  #実行のみ
  def test_2
    tsukasa = Tsukasa::Control.new() do
      _EXIT_
    end

    tsukasa.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
    
    reslut = [[:_SET_,
                {:id=>:"Tsukasa::Control",
                 :child_update=>true,
                 :script_parser=>{},
                 :exit=>true},
                {}]]
    assert_equal(tsukasa.serialize(), reslut, "NO")
  end

  #実行のみ
  def test_3
    tsukasa = Tsukasa::Control.new() do
      _DEFINE_PROPERTY_ test: 3
      _EXIT_
    end

    tsukasa.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
    
    reslut = [[:_SET_,
                {:id=>:"Tsukasa::Control",
                 :test=>3,
                 :child_update=>true,
                 :script_parser=>{},
                 :exit=>true},
                {}]]
    assert_equal(tsukasa.serialize(), reslut, "NO")
  end

  #実行のみ
  def test_4
    tsukasa = Tsukasa::Control.new() do
      _CREATE_:Image, id: :test_image
      _EXIT_
    end

    tsukasa.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
    
    reslut = [[:_SET_, 
              { :path=>nil, 
                :visible=>true, 
                :scale_x=>1, 
                :scale_y=>1, 
                :center_x=>nil, 
                :center_y=>nil, 
                :alpha=>255, 
                :blend=>:alpha, 
                :color=>[255, 255, 255], 
                :angle=>0, 
                :z=>0, 
                :shader=>nil, 
                :offset_sync=>false, 
                :x=>0, 
                :y=>0, 
                :offset_x=>0, 
                :offset_y=>0, 
                :float_x=>nil, 
                :float_y=>nil, 
                :align_x=>nil, 
                :align_y=>nil, 
                :width=>1, 
                :height=>1, 
                :id=>:test_image, 
                :child_update=>true, 
                :script_parser=>nil, 
                :exit=>false}, 
              {}]]
    assert_equal(tsukasa.find_control(:test_image).serialize(), reslut, "NO")
  end
end