#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver1.2(2016/3/1)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2016> <tsukasa TSUCHIYA>
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

_CREATE_ :LayoutControl, id: :requested_close do
  _STACK_LOOP_ do
    #ウィンドウの閉じるボタンが押された場合に呼びだされる。
    _CHECK_ system: [:requested_close] do
      _EXIT_ #アプリを終了する
    end
    
    _SEND_ROOT_ do
      _CHECK_ mouse: :cursor_out do
        #カーソルを表示する
        Input.mouse_enable = true unless @_SYSTEM_[:_CURSOR_VISIBLE_]
      end

      _CHECK_ mouse: :cursor_over do
        #カーソルを不可視に戻す
        Input.mouse_enable = false unless @_SYSTEM_[:_CURSOR_VISIBLE_]
      end
    end
    
    _END_FRAME_
  end
end

#スクリーンショットキャプチャ
_DEFINE_ :_CAPTURE_SS_ do |file_path, options|
  Window.get_screen_shot(file_path, options[:format] || FORMAT_PNG)
end

#ファイルオープンダイアログ
_DEFINE_ :_OPEN_FILENAME_ do |title , options|
  _YIELD_ Window.open_filename(options[:filter ] || [], title || "")
end

#ファイルセーブダイアログ
_DEFINE_ :_SAVE_FILENAME_ do |title , options|
  _YIELD_ Window.save_filename(options[:filter ] || [], title || "")
end

#フォルダダイアログ
_DEFINE_ :_FOLDER_DIALOG_ do |title , options|
  _YIELD_ Window.folder_dialog(title || "", options[:default_dir ] || "", )
end

#アプリを起動してからのミリ秒を取得する
_DEFINE_ :_RUNNING_TIME_ do 
  _YIELD_ Window.running_time
end

#フルスクリーンのオンオフ
_DEFINE_ :_FULL_SCREEN_ do |argument|
      Window.full_screen = argument #bool
end

#フルスクリーン化可能な解像度のリストを取得する
_DEFINE_ :_SCREEN_MODES_ do 
  _YIELD_ Window.get_screen_modes
end

#画面サイズの変更
_DEFINE_ :_RESIZE_ do |argumnet, options|
  Window.resize(options[:width], options[:height])
  _SEND_ROOT_ do
    _SET_ width: options[:width], height: options[:height]
  end
end

_DEFINE_ :_WINDOW_STATUS_ do |argumnet, options|
  #タイトルバーの文字列を設定する
  Window.caption = options[:caption] if options[:caption]
  #タイトルバーのアイコン画像を設定する
  Window.load_icon(options[:icon_path])if options[:icon_path]
  
  #マウスカーソルの形状を設定する。
    #マウスカーソル定数
    #IDC_APPSTARTING 標準の矢印カーソルと小さい砂時計カーソル
    #IDC_ARROW 標準の矢印カーソル
    #IDC_CROSS 十字カーソル
    #IDC_HAND ハンドカーソル
    #IDC_HELP 矢印と疑問符
    #IDC_IBEAM アイビーム（ 縦線）カーソル
    #IDC_NO 禁止カーソル（ 円に左上から右下への斜線）
    #IDC_SIZEALL 4 方向の矢印カーソル
    #IDC_SIZENESW 右上と左下を指す両方向矢印カーソル
    #IDC_SIZENS 上下を指す両方向矢印カーソル
    #IDC_SIZENWSE 左上と右下を指す両方向矢印カーソル
    #IDC_SIZEWE 左右を指す両方向矢印カーソル
    #IDC_UPARROW 上を指す垂直の矢印カーソル
    #IDC_WAIT 砂時計カーソル
  Input.set_cursor(options[:cursor_type]) if options[:cursor_type]
end

_DEFINE_ :_CURSOR_VISIBLE_ do |argumnet|
  @_SYSTEM_[:_CURSOR_VISIBLE_] = argumnet
  Input.mouse_enable = argumnet
end

###############################################################################
#テキストレイヤ関連
###############################################################################

#標準ポーズコマンド
_DEFINE_ :pause do
  #スリープフラグを立てる
  _SET_ :_TEMP_, _SLEEP_: true
  #スリープフラグが下りるまで待機
  _WAIT_ :_TEMP_, 
          key_down: K_RCONTROL, 
          equal: {_SLEEP_: false}
end

#行クリック待ちポーズ
_DEFINE_ :line_pause do
  #テキストレイヤのクリック待ち
  _SEND_DEFAULT_ :TextLayer do 
    _PAUSE_ do
      _CREATE_ :RenderTargetControl, id: :icon, 
        width: 24, height: 24, align_y: :bottom, float_x: :left, z: 100000 do
        _CREATE_ :TileMapControl, 
          map_array: [[0]], size_x: 1, size_y: 1 do
            _SET_IMAGE_MAPPING_ file_path: "./resource/icon/icon_8_a.png",
              x_count: 4, y_count: 2
          _INCLUDE_ "./resource/icon/icon_8_a.rb"
        end
      end
    end
  end

  #ルートのクリック待ち
  pause 

  #クリック待ちアイコンを削除
  _CHECK_ :_TEMP_, not_equal: {_SKIP_: true} do
    _SEND_DEFAULT_ :TextLayer do 
      _SEND_TO_ACTIVE_LINE_ do 
        _SEND_ :icon do
          _DELETE_
        end
      end
    end
  end
end

#行クリック待ちポーズ(line_pauseの省略板)
_DEFINE_ :lp do
  line_pause
end

_DEFINE_ :end_pause do
  #テキストレイヤのクリック待ち
  _SEND_DEFAULT_ :TextLayer do 
    _PAUSE_ do
      _CREATE_ :RenderTargetControl, id: :icon, 
        width: 24, height: 24, align_y: :bottom, float_x: :left, z: 100000 do
        _CREATE_ :TileMapControl, 
          map_array: [[0]], size_x: 1, size_y: 1 do
          _SET_IMAGE_MAPPING_ file_path: "./resource/icon/icon_4_a.png",
            x_count: 4, y_count: 1
          _STACK_LOOP_ do
            _SET_TILE_ x:0, y:0, id:0
            _WAIT_ count: 5
            _SET_TILE_ x:0, y:0, id:1
            _WAIT_ count: 5
            _SET_TILE_ x:0, y:0, id:2
            _WAIT_ count: 5
            _SET_TILE_ x:0, y:0, id:3
            _WAIT_ count: 5
          end
        end
      end
    end
  end

  #ルートのクリック待ち
  pause 

  #クリック待ちアイコンを削除
  _CHECK_ :_TEMP_, not_equal: {_SKIP_: true} do
    _SEND_DEFAULT_ :TextLayer do 
      _SEND_TO_ACTIVE_LINE_ do 
        _SEND_ :icon do
          _DELETE_
        end
      end
    end
  end
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
    id: argument,
    font_name: "ＭＳＰ ゴシック" do
      #文字間ウェイト
      _DEFINE_ :_CHAR_WAIT_ do
        _WAIT_  :_TEMP_, count: 2,
                key_down: K_RCONTROL,
                key_push: K_SPACE,
                system: [:key_down],
                equal: {_SKIP_: true}
      end
      #行間ウェイト
      _DEFINE_ :_LINE_WAIT_ do
        _WAIT_  :_TEMP_, count: 2,
                key_down: K_RCONTROL,
                key_push: K_SPACE,
                system: [:key_down],
                equal: {_SKIP_: true}
      end
      #文字レンダラ
      _DEFINE_ :_CHAR_RENDERER_ do
        #フェードイン（スペースキーか右CTRLが押されたらスキップ）
        _MOVE_   30, alpha:[0,255],
              option: {check: { key_down: K_RCONTROL, 
                                key_push: K_SPACE,
                                system: [:key_down],
                                equal: {_SKIP_: true}},
                       datastore: :_TEMP_} do
                _SET_ alpha: 255
              end
        #トランジションが終了するまで待機
        _WAIT_  not_stack_command: :_MOVE_ 
        #待機フラグが下がるまで待機
        _WAIT_ :_TEMP_, equal: {_SLEEP_: false}
        #キー入力伝搬を防ぐ為に１フレ送る
        _END_FRAME_
        #ハーフフェードアウト（スペースキーか右CTRLが押されたらスキップ）
        _MOVE_  60,  alpha:128,
              option: {
              check: {key_down: K_RCONTROL, 
                      key_push: K_SPACE,
                      system: [:key_down]
                      }} do
                #スキップされた場合
                _CHECK_ key_down: K_RCONTROL,
                        equal: {_SKIP_: true} do
                  #CTRLスキップ中であれば透明度255
                  _SET_ alpha: 255
                end
                _CHECK_ key_push: K_SPACE,
                        system: [:key_down] do
                  #CTRLスキップ中でなければ透明度128
                  _SET_ alpha: 128
                end
        end
        #トランジションが終了するまで待機
        _WAIT_ not_stack_command: :_MOVE_ 
      end

      #文字間ウェイトの更新
      _DEFINE_ :_WAIT_FRAME_ do |argument|
        _DEFINE_ :_CHAR_WAIT_ do
          _WAIT_  count: argument,
                  key_down: K_RCONTROL,
                  key_push: K_SPACE,
                  system: [:key_down]
        end
      end
      
      #アクティブ行への送信
      _DEFINE_ :_SEND_TO_ACTIVE_LINE_ do
        _SEND_ -1 do
          _YIELD_
        end
      end

      #キー入力待ち処理
      _DEFINE_ :_PAUSE_ do 
        _WAIT_  count:32,
                key_down: K_RCONTROL,
                key_push: K_SPACE,
                system: [:key_down],
                equal: {_SKIP_: true}

        _END_FRAME_

        #クリック待ちアイコンの表示
        _CHECK_ :_TEMP_, not_equal: {_SKIP_: true} do
          _CHECK_ system: [:block_given] do
            _SEND_TO_ACTIVE_LINE_ do
              _YIELD_
            end
          end
        end

        #スペースキーあるいはCTRLキーの押下待機
        _WAIT_  key_down: K_RCONTROL,
                key_push: K_SPACE,
                system: [:key_down],
                equal: {_SKIP_: true}

        #ウェイクに移行
        _SET_ :_TEMP_, _SLEEP_: false
      end
  end
end

#初期テキストウィンドウ
#初期レイヤ（背景）
_CREATE_ :ImageControl,
  z: 0, #描画順序
  id: :base do
end

#初期レイヤ０
_CREATE_ :ImageControl,
  z: 1000, #描画順序
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

TextWindow :text0, text_page_id: :default_text_page_control0,
  x: 96,
  y: 256 + 164,
  width: 1024,
  height: 192,
  z: 1000000 #描画順序

###############################################################################
#汎用コントロール
###############################################################################

#ボタンコントロール
_DEFINE_ :button do |argument, options|
  _CREATE_ :ClickableLayoutControl, 
    x: options[:x] || 0,
    y: options[:y] || 0,
    width:256, 
    height:256,
    id: argument do
    _CREATE_ :TileMapControl, 
      width: 256,
      height: 256 do
      _SET_ map_array: [[0]]
      _SET_IMAGE_ 0, file_path: "./resource/button_normal.png"
      _SET_IMAGE_ 1, file_path: "./resource/button_over.png"
      _SET_IMAGE_ 2, file_path: "./resource/button_key_down.png"
    end
    _STACK_LOOP_ do
      _END_FRAME_
      _CHECK_ mouse: [:cursor_over] do
        _SEND_(0){ _SET_TILE_ x:0, y:0, id: 1}
      end
      _CHECK_ mouse: [:cursor_out] do
        _SEND_(0){ _SET_TILE_ x:0, y:0, id: 0}
      end
      _CHECK_ mouse: [:key_down] do
        _SEND_(0){ _SET_TILE_ x:0, y:0, id: 2}
      end
      _CHECK_ mouse: [:key_up] do
        _SEND_(0){ _SET_TILE_ x:0, y:0, id: 1}
      end
      _CHECK_ system: [:block_given] do
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
  _EVAL_ "@_RESULT_[:#{options[:chapter].to_s}].push(#{options[:id]}).uniq!"

  ###################################################################
  #テキスト評価
  ###################################################################
  _YIELD_ 
end
