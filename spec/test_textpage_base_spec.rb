#! ruby -E utf-8
require 'spec_helper'
require 'dxruby'
require './system/Tsukasa.rb'
#文字描画
require './system/Char.rb'
#テキストページ管理
require './system/TextPage.rb'

RSpec.describe Tsukasa::Control do

  it "2017_1_11_1_テキスト表示テスト" do
    #コントロールの生成
    control = Tsukasa::TextPage.new([nil,nil,nil], {}) do
      _TEXT_ "テキストウィンドウテスト表示１"
      _LINE_FEED_
      _TEXT_ "テキストウィンドウテスト表示１"
      _LINE_FEED_
      _TEXT_ "テキストウィンドウテスト表示１"
      _LINE_FEED_
      _HALT_
      _FLUSH_
      _TEXT_ "テキストウィンドウテスト表示２"
      _LINE_FEED_
      _TEXT_ "テキストウィンドウテスト表示２"
      _LINE_FEED_
      _TEXT_ "テキストウィンドウテスト表示２"
      _LINE_FEED_
      _HALT_
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
  end

  it "2017_1_11_2_レンダリング済みフォント表示テスト" do
    #コントロールの生成
    control = Tsukasa::Window.new() do
      #デフォルトのユーザー定義コマンド群の読み込み
      _INCLUDE_ "./plugin_script/default_script.rb"

      _INSTALL_PRERENDER_FONT_ "./resource/Fonts/FontData02.dat", font_name: "test_font_01"
      _CREATE_ :TextPage, font_name: "test_font_01" do
        _TEXT_ "レンダリング済みフォント表示１"
        _LINE_FEED_
        _TEXT_ "レンダリング済みフォント表示１"
        _LINE_FEED_
        _TEXT_ "レンダリング済みフォント表示１"
        _LINE_FEED_
        _HALT_
        _FLUSH_
        _TEXT_ "レンダリング済みフォント表示２"
        _LINE_FEED_
        _TEXT_ "レンダリング済みフォント表示２"
        _LINE_FEED_
        _TEXT_ "レンダリング済みフォント表示２"
        _LINE_FEED_
        _HALT_
      end
      _LOOP_ 2 do
        _HALT_
      end
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
  end

  it "2017_1_12_1_標準テキストウィンドウ表示テスト" do
    #コントロールの生成
    control = Tsukasa::Window.new() do
      #プラグインスクリプトファイルの読み込み
      Dir.glob("./plugin_script/*.rb").each do |path|
        _INCLUDE_ path
      end

      #キー入力管理コントロール
      _CREATE_ :Input, id: :_INPUT_

      #初期テキストウィンドウ
      _TEXT_WINDOW_ :text0, 
        x: 96,
        y: 256,
        size: 32, 
        font_name: "ＭＳＰ ゴシック",
        z: 1000000 #描画順序
      #初期テキストウィンドウのidを格納
      _DEFINE_PROPERTY_ _DEFAULT_TEXT_PAGE_: [:_ROOT_, :text0]

      _CHAR_RUBI_ "□□□□□□□"
      _SEND_ [:_ROOT_, :text0] do
        _TEXT_ "■■■■■■■"
      end
      _LOOP_ 60 do
        _HALT_
      end
      #_END_PAUSE_

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
  end

  it "2017_1_12_2_テキストウィンドウ画像表示テスト" do
    #コントロールの生成
    control = Tsukasa::Window.new() do
      #プラグインスクリプトファイルの読み込み
      Dir.glob("./plugin_script/*.rb").each do |path|
        _INCLUDE_ path
      end

      #キー入力管理コントロール
      _CREATE_ :Input, id: :_INPUT_

      #初期テキストウィンドウ
      _TEXT_WINDOW_ :text0, 
        x: 96,
        y: 256,
        size: 32, 
        font_name: "ＭＳＰ ゴシック",
        z: 1000000 #描画順序
      #初期テキストウィンドウのidを格納
      _DEFINE_PROPERTY_ _DEFAULT_TEXT_PAGE_: [:_ROOT_, :text0]

      _CHAR_IMAGE_ "./resource/button_key_up.png", width:256,height:256
      _SEND_ [:_ROOT_, :text0] do
        _TEXT_ "外字画像表示テスト"
      end
      _LOOP_ 60 do
        _HALT_
      end
      #_END_PAUSE_

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
  end


=begin


  def test_2017_1_12_2_テキストウィンドウ画像表示テスト
    #コントロールの生成
    control = Tsukasa::Window.new() do
      #プラグインスクリプトファイルの読み込み
      Dir.glob("./plugin_script/*.rb").each do |path|
        _INCLUDE_ path
      end

      #キー入力管理コントロール
      _CREATE_ :Input, id: :_INPUT_

      #初期テキストウィンドウ
      _TEXT_WINDOW_ :text0, 
        x: 96,
        y: 256,
        size: 32, 
        font_name: "ＭＳＰ ゴシック",
        z: 1000000 #描画順序
      #初期テキストウィンドウのidを格納
      _DEFINE_PROPERTY_ _DEFAULT_TEXT_PAGE_: [:_ROOT_, :text0]

      _CHAR_IMAGE_ "./resource/button_key_up.png", width:256,height:256
      _SEND_ [:_ROOT_, :text0] do
        _TEXT_ "外字画像表示テスト"
      end
      _LOOP_ 60 do
        _HALT_
      end
      #_END_PAUSE_

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

=end
end
