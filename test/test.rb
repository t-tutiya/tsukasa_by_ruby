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

  #プロパティとの比較によるテスト
  def test_2
    #コントロールの生成
    control = Tsukasa::Control.new() do
      #動的プロパティの追加
      _DEFINE_PROPERTY_ test: 0
      #５０フレームかけてtestの値を０から１００まで遷移させる
      _MOVE_ 50, test:[0,100]
      #メインループを終了する
      _EXIT_
    end

    #メインループ
    DXRuby::Window.loop() do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0) #処理
      control.render(0, 0, DXRuby::Window) #描画
      break if control.exit #メインループ終了判定
    end

    #テスト
    assert_equal(control.test, 100)
  end

  #メインループを回さないテスト
  def test_3
    #コントロールの生成
    control = Tsukasa::Control.new() do
      #動的プロパティの追加
      _DEFINE_PROPERTY_ test: 3
      #５０フレームかけてtestの値を０から１００まで遷移させる
      _MOVE_ 50, test:[0,100]
      #メインループを終了する
      _EXIT_
    end

    #２５フレーム回したと想定
    25.times do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
    end

    #テスト
    assert_equal(control.test, 50)
  end

  #複数フレームにわたる値の変化を比較するテスト
  def test_4
    #コントロールの生成
    control = Tsukasa::Control.new() do
      #動的プロパティの追加
      _DEFINE_PROPERTY_ test: 0
      #１０フレームかけてin_quadイージングでtestの値を０から１００まで遷移させる
      _MOVE_ [10, :in_quad], test:[0,100]
      #メインループを終了する
      _EXIT_
    end

    result = []

    #１０フレーム回したと想定
    10.times do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
      result.push(control.test)
    end

    #テスト
    #第１フレが０から始まってないのがあってるのかどうかよくわからぬ。
    assert_equal(result, [1, 4, 9, 16, 25, 36, 48, 64, 81, 100])
  end

  #ゲーム側で判定タイミングのトリガーを用意するテスト
  def test_5
    puts "zキーを押してください"
    #コントロールの生成
    control = Tsukasa::Control.new() do
      #動的プロパティの追加
      _DEFINE_PROPERTY_ test: nil
      #無限ループ
      _LOOP_ do
        #zキーが押された場合
        _CHECK_INPUT_ key_down: Tsukasa::K_Z do
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


  #実行のみ
  def test_b_2
    control = Tsukasa::Control.new() do
      _EXIT_
    end

    control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
    
    reslut = [[:_SET_,
                {:id=>:"Tsukasa::Control",
                 :child_update=>true,
                 :script_parser=>{},
                 :exit=>true},
                {}]]
    assert_equal(control.serialize(), reslut)
  end

  #実行のみ
  def test_b_3
    control = Tsukasa::Control.new() do
      _DEFINE_PROPERTY_ test: 3
      _EXIT_
    end

    control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
    
    reslut = [[:_SET_,
                {:id=>:"Tsukasa::Control",
                 :test=>3,
                 :child_update=>true,
                 :script_parser=>{},
                 :exit=>true},
                {}]]
    assert_equal(control.serialize(), reslut)
  end

  #実行のみ
  def test_b_4
    control = Tsukasa::Control.new() do
      _CREATE_:Image, id: :test_image
      _EXIT_
    end

    control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
    
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
    assert_equal(control.find_control(:test_image).serialize(), reslut)
  end

  #通常ループ
  def test_b_5
    control = Tsukasa::Control.new() do
      _DEFINE_PROPERTY_ test: 3
      _MOVE_ 30, test:[40,400]
      _EXIT_
    end

    DXRuby::Window.loop() do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y, 0)
      control.render(0, 0, DXRuby::Window)
      break if control.exit
    end
    
    assert_equal(control.serialize()[0][1][:test], 400, "NO")
  end
end