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


RSpec.describe Tsukasa::Control do

  it '2016_12_31_1_コントロールのダンプとの比較' do
    #コントロールの生成
    control = Tsukasa::Control.new() do
      #メインループを終了する
      _EXIT_
    end

    #メインループ
    DXRuby::Window.loop() do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y) #処理
      control.render(0, 0, DXRuby::Window) #描画
      break if control.exit #メインループ終了判定
    end
    
    reslut = [[:_SET_, 
                {:id=>:"Tsukasa::Control",
                 :child_update=>true},
                ]]

    #テスト
    expect(control.serialize()).to eq(reslut)
  end

  it "2016_12_31_2_ユーザー定義コマンドの実行" do
    #コントロールの生成
    control = Tsukasa::Control.new() do
      _DEFINE_ :test0105_1 do
        _PUTS_ "test"
      end
      test0105_1
      #メインループを終了する
      _EXIT_
    end


    #メインループ
    DXRuby::Window.loop() do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y) #処理
      control.render(0, 0, DXRuby::Window) #描画
      break if control.exit #メインループ終了判定
    end

  end

  #プロパティとの比較によるテスト
  it "2016_12_31_3_プロパティとの比較によるテスト" do
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
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y) #処理
      control.render(0, 0, DXRuby::Window) #描画
      break if control.exit #メインループ終了判定
    end

    #テスト
    expect(control.test).to eq(100)
  end

  #メインループを回さないテスト
  it "2016_12_31_4_メインループを回さないテスト" do
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
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y)
    end

    #テスト
    expect(control.test).to eq(50)
  end

  #複数フレームにわたる値の変化を比較するテスト
  it "2016_12_31_5_複数フレームに渡る値群の比較" do
    #コントロールの生成
    control = Tsukasa::Control.new() do
      #動的プロパティの追加
      _DEFINE_PROPERTY_ test: 0
      #１０フレームかけてin_quadイージングでtestの値を０から１００まで遷移させる
      _MOVE_ [10, easing: :in_quad], test:[0,100]
      #メインループを終了する
      _EXIT_
    end

    result = []

    #１０フレーム回したと想定
    10.times do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y)
      result.push(control.test.to_i)
    end

    #テスト
    #第１フレが０から始まってないのがあってるのかどうかよくわからぬ。
    expect(result).to eq([1, 4, 9, 16, 25, 36, 48, 64, 81, 100])
  end

  #実行のみ_シリアライズ配列との比較
  it "2016_12_31_6" do
    control = Tsukasa::Control.new() do
      _EXIT_
    end

    control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y)
    
    reslut = [[:_SET_, 
                {:id=>:"Tsukasa::Control",
                 :child_update=>true},
                ]]

    #テスト
    expect(control.serialize()).to eq(reslut)
  end

  #実行のみ
  it "2016_12_31_7_ループ外での実行_シリアライズ配列との比較_動的プロパティ追加" do
    control = Tsukasa::Control.new() do
      _DEFINE_PROPERTY_ test: 3
      _EXIT_
    end

    control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y)
    
    reslut = [[:_SET_, 
                {:id=>:"Tsukasa::Control",
                 :test=>3,
                 :child_update=>true},
                ]]

    #テスト
    expect(control.serialize()).to eq(reslut)
  end

  #実行のみ
  it "2016_12_31_8_ループ外での実行_任意コントロールのシリアライズ配列との比較" do
    control = Tsukasa::Control.new() do
      _CREATE_:Image, id: :test_image, width: 255, height:255
      _EXIT_
    end

    control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y)
    
    reslut = [[:_SET_, 
              { :path=>nil, 
                :visible=>true, 
                :scale_x=>1, 
                :scale_y=>1, 
                :center_x=>nil, 
                :center_y=>nil, 
                :alpha=>255, 
                :blend=>:alpha, 
                :color=>[0, 0, 0, 0], 
                :angle=>0, 
                :z=>0, 
                :shader=>nil, 
                :offset_sync=>false, 
                :x=>0, 
                :y=>0, 
                :id=>:test_image, 
                :child_update=>true}, 
              ]]

    #テスト
    expect(control.find_control(:test_image).serialize()).to eq(reslut)
  end

  #通常ループ
  it "2016_12_31_9_MOVE動作チェック_シリアライズ配列からプロパティ要素を取得する" do
    control = Tsukasa::Control.new() do
      _DEFINE_PROPERTY_ test: 3
      _MOVE_ 30, test:[40,400]
      _EXIT_
    end

    DXRuby::Window.loop() do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y)
      control.render(0, 0, DXRuby::Window)
      break if control.exit
    end
    
    #テスト
    expect(control.serialize()[0][1][:test]).to eq(400)
  end


  it "2017_01_09_1_デバッグコマンド動作確認" do
    control = Tsukasa::Window.new() do
      _DEBUG_TREE_
      _DEBUG_PROP_
      _DEBUG_COMMAND_
      _EXIT_
    end

    DXRuby::Window.loop() do
      control.update(DXRuby::Input.mouse_x, DXRuby::Input.mouse_y)
      control.render(0, 0, DXRuby::Window)
      break if control.exit
    end
    
  end
end
