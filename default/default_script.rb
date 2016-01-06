#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver1.0(2015/12/24)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2015> <tsukasa TSUCHIYA>
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

###############################################################################
#システムサポート
###############################################################################

_CREATE_ :LayoutControl do
  _NEXT_LOOP_ do
    #ウィンドウの閉じるボタンが押された場合に呼びだされる。
    _CHECK_ window: [:requested_close] do
      _EXIT_ #アプリを終了する
    end
  end
end

#指定フレーム数ウェイト
#ex. wait_count 60
_DEFINE_ :wait_count do |argument, options|
  _WAIT_ count: argument
end

#指定コマンドウェイト
#ex. wait_command :_MOVE_ 
_DEFINE_ :wait_command do |argument, options|
  _WAIT_ command: argument
end

###############################################################################
#テキストレイヤ関連
###############################################################################

#標準ポーズコマンド
_DEFINE_ :pause do |argument, options|
  _SEND_ default: :TextLayer do 
    pause options
  end

  #■ルートの待機処理
  #スリープ状態に移行
  _SET_ :_TEMP_, sleep: true

  #ウェイク状態まで待機
  _WAIT_ :_TEMP_,  key_down: K_RCONTROL, 
          equal: {sleep: false} do
    _CHECK_ window: [:block_given] do
      _YIELD_
    end
  end

#クリック待ちアイコンを削除
  _SEND_ default: :TextLayer do 
    _SEND_ :icon do
      _DELETE_
    end
  end

  #１フレ分は必ず表示させる
  _END_FRAME_ 
end

#行クリック待ちポーズ
_DEFINE_ :line_pause do
  pause icon: :line_icon_func
end

#行クリック待ちポーズ(line_pauseの省略板)
_DEFINE_ :lp do
  line_pause
end

_DEFINE_ :end_pause do
  pause icon: :page_icon_func
end

_DEFINE_ :ep do
  end_pause
end

###############################################################################
#デフォルトのレイヤ群
###############################################################################

#標準テキストウィンドウ
_DEFINE_ :TextWindow do |argument, options|
  #メッセージウィンドウ
  _CREATE_ :TextPageControl, 
    x: options[:x] || 0,
    y: options[:y] || 0,
    width: options[:width],
    height: options[:height],
    size: 32, 
    id: options[:id],
    font_name: "ＭＳＰ ゴシック" do
      _DEFINE_ :_CHAR_WAIT_ do
        _WAIT_  :_TEMP_, count: 2,
                key_down: K_RCONTROL,
                key_push: K_SPACE,
                window: [:key_down],
                equal: {_SKIP_: true}
      end
      _DEFINE_ :_LINE_WAIT_ do
        _WAIT_  :_TEMP_, count: 2,
                key_down: K_RCONTROL,
                key_push: K_SPACE,
                window: [:key_down],
                equal: {_SKIP_: true}
      end
      _DEFINE_ :_CHAR_RENDERER_ do
        #フェードイン（スペースキーか右CTRLが押されたらスキップ）
        _MOVE_   30, alpha:[0,255],
              option: {check: { key_down: K_RCONTROL, 
                                key_push: K_SPACE,
                                window: [:key_down],
                                equal: {_SKIP_: true}},
                       datastore: :_TEMP_} do
                _SET_ alpha: 255
              end
        #トランジションが終了するまで待機
        _WAIT_  command: :_MOVE_ 
        #待機フラグを立てる
        _SET_ :_TEMP_, sleep: true
        #待機フラグが下がるまで待機
        _WAIT_ :_TEMP_, equal: {sleep: false}
        #キー入力伝搬を防ぐ為に１フレ送る
        _END_FRAME_
        #ハーフフェードアウト（スペースキーか右CTRLが押されたらスキップ）
        _MOVE_  60,  alpha:128,
              option: {
              check: {key_down: K_RCONTROL, 
                      key_push: K_SPACE,
                      window: [:key_down]
                      }} do
                #スキップされた場合
                _CHECK_ key_down: K_RCONTROL,
                        equal: {_SKIP_: true} do
                  #CTRLスキップ中であれば透明度255
                  _SET_ alpha: 255
                end
                _CHECK_ key_push: K_SPACE,
                        window: [:key_down] do
                  #CTRLスキップ中でなければ透明度128
                  _SET_ alpha: 128
                end
        end
        #トランジションが終了するまで待機
        _WAIT_ command: :_MOVE_ 
      end
      #文字間待ち時間
      _DEFINE_ :_WAIT_FRAME_ do |argument, options|
        _DEFINE_ :_CHAR_WAIT_ do
          _WAIT_  count: argument,
                  key_down: K_RCONTROL,
                  key_push: K_SPACE,
                  window: [:key_down]
        end
      end
      #キー入力待ち処理
      _DEFINE_ :pause do |argument, options|
        _WAIT_ count:17
        _SEND_ -1 do
          if options[:icon] == :line_icon_func
              line_icon_func align_y: :bottom, float_x: :left
          else
              page_icon_func align_y: :bottom, float_x: :left
          end
        end

        #スペースキーあるいはCTRLキーの押下待機
        _WAIT_  key_down: K_RCONTROL,
                key_push: K_SPACE,
                window: [:key_down],
                equal: {_SKIP_: true}

        #ウェイクに移行
        _SET_ :_TEMP_, sleep: false
      end

      _SET_ size: 32

      _CHECK_ window: [:block_given] do
        _YIELD_
      end
  end
end

TextWindow id: :text0, text_page_id: :default_text_page_control0,
  x: 96,
  y: 256 + 164,
  width: 1024,
  height: 192,
  z: 1000000 #描画順序

=begin
#全画面の場合
TextWindow id: :text1, text_page_id: :default_text_page_control0,
  x: 64,
  y: 64,
  width: 1024,
  height: 768,
  z: 1000000 #描画順序
=end

_DEFINE_ :line_icon_func do |argument, options|
  _CREATE_ :RenderTargetControl, 
          :x => options[:x] || 0, 
          :y => options[:y] || 0, 
          :width => 24,
          :height => 24,
          :align_y => options[:align_y] || :bottom,
          :float_x => options[:float_x] || :left,
          :id => :icon do
    _CREATE_ :TileImageControl, 
            :tiles => true,
            :file_path=>"./resource/icon/icon_8_a.png", 
            :x_count => 4, 
            :y_count => 2 do
      _INCLUDE_ "./resource/icon/icon_8_a.rb"
    end
    _CHECK_ window: [:block_given] do
      _YIELD_
    end
  end
end

_DEFINE_ :page_icon_func do |argument, options|
  _CREATE_ :RenderTargetControl, 
          :x => options[:x] || 0, 
          :y => options[:y] || 0, 
          :width => 24,
          :height => 24,
          :align_y => options[:align_y] || :bottom,
          :float_x => options[:float_x] || :left,
          :id => :icon do
    _CREATE_ :TileImageControl, 
            :tiles => true, 
            :file_path=>"./resource/icon/icon_4_a.png", 
            :x_count => 4, 
            :y_count => 1 do
      _NEXT_LOOP_ do
        _SEND_(3){_SET_  visible: false}
        _SEND_(0){_SET_  visible: true}
      	_WAIT_  count: 5
        _SEND_(0){_SET_  visible: false}
        _SEND_(1){_SET_  visible: true}
      	_WAIT_  count: 5
        _SEND_(1){_SET_  visible: false}
        _SEND_(2){_SET_  visible: true}
      	_WAIT_  count: 5
        _SEND_(2){_SET_  visible: false}
        _SEND_(3){_SET_  visible: true}
      	_WAIT_  count: 5
      end
    end
    _CHECK_ window: [:block_given] do
      _YIELD_
    end
  end
end

#初期レイヤ（背景）
_CREATE_ :ImageControl,
  z: 0, #描画順序
  id: :base do
end

#初期レイヤ０
_CREATE_ :ImageControl,
  z: 100, #描画順序
  id: :img0 do
end

#初期レイヤ１
_CREATE_ :ImageControl,
  z: 2000, #描画順序
  id: :img1 do
end

#初期レイヤ２
_CREATE_ :ImageControl,
  z: 3000, #描画順序
  id: :img2 do
end

###############################################################################
#汎用コントロール
###############################################################################

#ボタンコントロール
_DEFINE_ :button do |argument, options|
  _CREATE_ :LayoutControl, 
          :x => options[:x] || 0,
          :y => options[:y] || 0,
          :width => 256,
          :height => 256,
          :id=>options[:id] do
    _CREATE_ :ImageControl, 
      :file_path=>"./resource/button_normal.png", 
      :id=>:normal
    _CREATE_ :ImageControl, 
      :file_path=>"./resource/button_over.png", 
      :id=>:over, :visible => false
    _CREATE_ :ImageControl, 
      :file_path=>"./resource/button_key_down.png", 
      :id=>:key_down, :visible => false
    _NEXT_LOOP_ do
      _CHECK_ mouse: [:cursor_over] do
        normal  {_SET_ visible: false}
        over    {_SET_ visible: true}
        key_down{_SET_ visible: false}
      end
      _CHECK_ mouse: [:cursor_out] do
        normal  {_SET_ visible: true}
        over    {_SET_ visible: false}
        key_down{_SET_ visible: false}
      end
      _CHECK_ mouse: [:key_down] do
        normal  {_SET_ visible: false}
        over    {_SET_ visible: false}
        key_down{_SET_ visible: true}
      end
      _CHECK_ mouse: [:key_up] do
        normal  {_SET_ visible: false}
        over    {_SET_ visible: true}
        key_down{_SET_ visible: false}
      end
      _CHECK_ window: [:block_given] do
        _YIELD_
      end
    end
  end
end

#既読管理ラベル
_DEFINE_ :_LABEL_ do |arugment, options|

  ###################################################################
  #初期値更新
  ###################################################################

  #チャプターの更新
  unless options[:chapter]
    options[:chapter] = _TEMP_[:_ACTIVE_SCENARIO_CHAPTER_]
  end
  
  #IDの更新
  unless options[:id]
    if _TEMP_[:_SCENARIO_CHAPTER_ID_][options[:chapter]]
      options[:id] = _TEMP_[:_SCENARIO_CHAPTER_ID_][options[:chapter]] + 1
    else
      options[:id] = 0
    end
  end

  ###################################################################
  #現在のチャプターを保存
  ###################################################################

  unless _TEMP_[:_SCENARIO_CHAPTER_ID_][options[:chapter]]
    _TEMP_[:_ACTIVE_SCENARIO_CHAPTER_] = options[:chapter]
  end

  _TEMP_[:_SCENARIO_CHAPTER_ID_][options[:chapter]] = options[:id]

  #新規チャプターであれば既読フラグに追加
  #TODO：結局チャプター名はゲーム全体で一意でなければならない
  unless _SYSTEM_[:_READ_CHAPTER_][options[:chapter]]
    _SYSTEM_[:_READ_CHAPTER_][options[:chapter]] = []
  end

  ###################################################################
  #頭出しモードの場合
  ###################################################################

  _CHECK_ equal: {_CHAPTER_START_MODE_: true} do
    #ページが指定したＩＤでない場合
    _CHECK_ :_LOCAL_, not_equal: {_START_: options[:id]} do
      #ページを飛ばす
      _RETURN_
    end
    #ラベルモードをノーマルに変更する
    _SET_ :_TEMP_, _CHAPTER_START_MODE_: false
  end

  ###################################################################
  #既読スキップモードの場合
  ###################################################################

  _CHECK_ equal: {_CHAPTER_SKIP_MODE_: true} do
    if(_SYSTEM_[:_READ_CHAPTER_][options[:chapter]].index(options[:id]))
      #スキップモードＯＮ
      _SET_ :_TEMP_, _SKIP_: true
    else
      #スキップモードＯＦＦ
      _SET_ :_TEMP_, _SKIP_: false
    end
  end

  ###################################################################
  #既読フラグを立てる処理
  ###################################################################

  #既読フラグハッシュが無ければ新設
  _CHECK_ :_SYSTEM_, equal: {_READ_CHAPTER_: nil} do
    _SET_ :_SYSTEM_, _READ_CHAPTER_: {}
  end

  #既読フラグハッシュを取得
  _GET_ :_SYSTEM_, _RESULT_: :_READ_CHAPTER_

  #チャプターが登録されていない場合登録
  _CHECK_ :_RESULT_, null: options[:chapter] do
    _SET_ :_RESULT_, {options[:chapter] => []}
  end

  ###################################################################
  #既読フラグ追加
  ###################################################################

  #TODO：これ無理矢理すぎるけど今の所pushを司スクリプトで処理できない
  _EVAL_ "@_RESULT_[:#{options[:chapter].to_s}].push(#{options[:id]})"

  ###################################################################
  #テキスト評価
  ###################################################################
  _YIELD_ 
end
