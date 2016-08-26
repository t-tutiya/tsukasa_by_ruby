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

_CREATE_ :ClickableLayout, id: :requested_close,
  width: DXRuby::Window.width, height: DXRuby::Window.height do
  _DEFINE_ :inner_loop do
    #ウィンドウの閉じるボタンが押された場合に呼びだされる。
    _CHECK_REQUESTED_CLOSE_ do
      _EXIT_ #アプリを終了する
      _RETURN_
    end
    
    _GET_ :_CURSOR_VISIBLE_, datastore: :_SYSTEM_ do |options|
      _CHECK_MOUSE_ :cursor_off do
        #カーソルを表示する
        DXRuby::Input.mouse_enable = true unless options[:_CURSOR_VISIBLE_]
      end

      _CHECK_MOUSE_ :cursor_on do
        #カーソルを不可視に戻す
        DXRuby::Input.mouse_enable = false unless options[:_CURSOR_VISIBLE_]
      end
    end
    _END_FRAME_
    _RETURN_ :inner_loop
  end
  inner_loop
end

#スクリーンショットキャプチャ
_DEFINE_ :_CAPTURE_SS_ do |path, options|
  DXRuby::Window.get_screen_shot(path, options[:format] || DXRuby::FORMAT_PNG)
end

#ファイルオープンダイアログ
_DEFINE_ :_OPEN_FILENAME_ do |title , options|
  _YIELD_ DXRuby::Window.open_filename(options[:filter ] || [], title || "")
end

#ファイルセーブダイアログ
_DEFINE_ :_SAVE_FILENAME_ do |title , options|
  _YIELD_ DXRuby::Window.save_filename(options[:filter ] || [], title || "")
end

#フォルダダイアログ
_DEFINE_ :_FOLDER_DIALOG_ do |title , options|
  _YIELD_ DXRuby::Window.folder_dialog(title || "", options[:default_dir ] || "", )
end

#アプリを起動してからのミリ秒を取得する
_DEFINE_ :_RUNNING_TIME_ do 
  _YIELD_ time: DXRuby::Window.running_time
end

#フルスクリーンのオンオフ
_DEFINE_ :_FULL_SCREEN_ do |_ARGUMENT_:|
      DXRuby::Window.full_screen = _ARGUMENT_ #bool
end

#フルスクリーン化可能な解像度のリストを取得する
_DEFINE_ :_SCREEN_MODES_ do 
  _YIELD_ screen_modes: DXRuby::Window.get_screen_modes
end

#FPSカウンタ
_DEFINE_ :_FPS_ do |_ARGUMENT_: false|
  DXRuby::Window.fps = _ARGUMENT_ if _ARGUMENT_
  _CHECK_BLOCK_ do
    _YIELD_ fps: DXRuby::Window.real_fps
  end
end

#画面サイズの変更
_DEFINE_ :_RESIZE_ do |options|
  DXRuby::Window.resize(options[:width], options[:height])
  _SEND_ [:_ROOT_, :requested_close] do
    _SET_ width: options[:width], height: options[:height]
  end
end

_DEFINE_ :_WINDOW_STATUS_ do |options|
  #タイトルバーの文字列を設定する
  DXRuby::Window.caption = options[:caption] if options[:caption]
  #タイトルバーのアイコン画像を設定する
  DXRuby::Window.load_icon(options[:icon_path])if options[:icon_path]
  #フレーム更新時のリセット背景色を設定する
  DXRuby::Window.bgcolor = options[:bgcolor] if options[:bgcolor]

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
  DXRuby::Input.set_cursor(options[:cursor_type]) if options[:cursor_type]
end

#マウスカーソルの可視設定
_DEFINE_ :_MOUSE_ENABLE_ do |_ARGUMENT_:|
  _SET_ :_SYSTEM_, _CURSOR_VISIBLE_: _ARGUMENT_
  DXRuby::Input.mouse_enable = _ARGUMENT_
end

#マウスホイールの値を設定／取得する
_DEFINE_ :_MOUSE_WHEEL_POS_ do |_ARGUMENT_: false|
  DXRuby::Input.mouse_wheel_pos = _ARGUMENT_ if _ARGUMENT_
  _CHECK_BLOCK_ do
    _YIELD_ pos: DXRuby::Input.mouse_wheel_pos
  end
end

#パッドの方向キーを-1,0,1で取得する
_DEFINE_ :_PAD_ARROW_ do |_ARGUMENT_:|
  _CHECK_BLOCK_ do
    _YIELD_ x: DXRuby::Input.x(_ARGUMENT_ || 0), y: DXRuby::Input.y(_ARGUMENT_ || 0)
  end
end

#パッドのキーコンフィグを設定する
_DEFINE_ :_PAD_CONFIG_ do |options|
  DXRuby::Input.set_config( options[:pad_code], 
                    options[:key_code], 
                    options[:pad_number] = 0)
end

#Imageを生成し、指定したコントロール配下を描画する
_DEFINE_ :_TO_IMAGE_ do 
  |_ARGUMENT_:, width: nil, height: nil, scale: nil, z: Float::INFINITY, visible: true|
  _GET_ [:width, :height] do |options|
    #width/heightのどちらかが設定されていない場合、現在の幅を使用する
    unless width and height
      width = options[:width]
      height= options[:height]
    end
    #新規Imageの生成（初期設定では不可視）
    _CREATE_ :Image, id: _ARGUMENT_, z: z, visible: false,
      width: width, height: height do
      #自身と並列の子コントロールを描画する（自身は除く）
      _DRAW_ [:_PARENT_], scale: scale
      #可視設定を更新する
      _SET_ visible: visible
      #ブロックコマンド実行
      _CHECK_BLOCK_ do
        _YIELD_
      end
    end
  end
  #Imageのコマンドリストを評価させるために１フレ送る
  _END_FRAME_
end

#一時truetypeフォントの登録
_DEFINE_ :_INSTALL_FONT_ do |_ARGUMENT_:|
  Char.install(_ARGUMENT_)
end

#プリレンダフォントデータの登録
_DEFINE_ :_INSTALL_PRERENDER_FONT_ do |_ARGUMENT_:, font_name:| 
  Char.install_prerender(font_name, _ARGUMENT_)
end

#ウィンドウの閉じるボタンが押されたかどうかの判定
_DEFINE_ :_CHECK_REQUESTED_CLOSE_ do
  if DXRuby::Input.requested_close?
    _YIELD_
  end
end

###############################################################################
#キャッシュ管理
###############################################################################

_DEFINE_ :_IMAGE_REGIST_ do |_ARGUMENT_:|
  Image.cache.regist(_ARGUMENT_, true)
end

_DEFINE_ :_IMAGE_DISPOSE_ do |_ARGUMENT_:|
  Image.cache.force_dispose(_ARGUMENT_)
end
