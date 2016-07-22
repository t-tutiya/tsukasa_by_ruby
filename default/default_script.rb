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

_CREATE_ :ClickableLayoutControl, id: :requested_close,
  width: Window.width, height: Window.height do
  _STACK_LOOP_ do
    #ウィンドウの閉じるボタンが押された場合に呼びだされる。
    _CHECK_ system: [:requested_close] do
      _EXIT_ #アプリを終了する
      _DELETE_
    end
    
    _GET_ :_CURSOR_VISIBLE_, datastore: :_SYSTEM_ do |arg, options|
      _CHECK_ mouse: [:cursor_off] do
        #カーソルを表示する
        Input.mouse_enable = true unless options[:_CURSOR_VISIBLE_]
      end

      _CHECK_ mouse: [:cursor_on] do
        #カーソルを不可視に戻す
        Input.mouse_enable = false unless options[:_CURSOR_VISIBLE_]
      end
    end
    _END_FRAME_
  end
end

#スクリーンショットキャプチャ
_DEFINE_ :_CAPTURE_SS_ do |path, options|
  Window.get_screen_shot(path, options[:format] || FORMAT_PNG)
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

#FPSカウンタ
_DEFINE_ :_FPS_ do |fps|
  Window.fps = fps if fps
  _CHECK_ system: :block_given do
    _YIELD_ Window.real_fps
  end
end

#画面サイズの変更
_DEFINE_ :_RESIZE_ do |argumnet, options|
  Window.resize(options[:width], options[:height])
  _SEND_ [:_ROOT_, :requested_close] do
    _SET_ width: options[:width], height: options[:height]
  end
end

_DEFINE_ :_WINDOW_STATUS_ do |argumnet, options|
  #タイトルバーの文字列を設定する
  Window.caption = options[:caption] if options[:caption]
  #タイトルバーのアイコン画像を設定する
  Window.load_icon(options[:icon_path])if options[:icon_path]
  #フレーム更新時のリセット背景色を設定する
  Window.bgcolor = options[:bgcolor] if options[:bgcolor]

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

#マウスカーソルの可視設定
_DEFINE_ :_MOUSE_ENABLE_ do |argumnet|
  _SET_ :_SYSTEM_, _CURSOR_VISIBLE_: argumnet
  Input.mouse_enable = argumnet
end

#マウスホイールの値を設定／取得する
_DEFINE_ :_MOUSE_WHEEL_POS_ do |argumnet|
  Input.mouse_wheel_pos = argumnet if argumnet
  _CHECK_ system: :block_given do
    _YIELD_ Input.mouse_wheel_pos
  end
end

#パッドの方向キーを-1,0,1で取得する
_DEFINE_ :_PAD_ARROW_ do |argumnet|
  _CHECK_ system: :block_given do
    _YIELD_ x: Input.x(argumnet || 0), y: Input.y(argumnet || 0)
  end
end

#パッドのキーコンフィグを設定する
_DEFINE_ :_PAD_CONFIG_ do |argumnet, options|
  Input.set_config( options[:pad_code], 
                    options[:key_code], 
                    options[:pad_number] = 0)
end

#ImageControlを生成し、指定したコントロール配下を描画する
_DEFINE_ :_TO_IMAGE_ do 
  |argument, width: nil, height: nil, scale: nil, z: Float::INFINITY, visible: true|
  _GET_ [:width, :height] do |arg, options|
    #width/heightのどちらかが設定されていない場合、現在の幅を使用する
    unless width and height
      width = options[:width]
      height= options[:height]
    end
    #新規ImageControlの生成（初期設定では不可視）
    _CREATE_ :ImageControl, id: argument, z: z, visible: false,
      width: width, height: height do
      #自身と並列の子コントロールを描画する（自身は除く）
      _DRAW_ [:_PARENT_], scale: scale
      #可視設定を更新する
      _SET_ visible: visible
      #ブロックコマンド実行
      _CHECK_ system: :block_given do
        _YIELD_
      end
    end
  end
  #ImageControlのコマンドリストを評価させるために１フレ送る
  _END_FRAME_
end

#一時truetypeフォントの登録
_DEFINE_ :_INSTALL_FONT_ do |path|
  CharControl.install(path)
end

#プリレンダフォントデータの登録
_DEFINE_ :_INSTALL_PRERENDER_FONT_ do |path, font_name:| 
  CharControl.install_prerender(font_name, path)
end

###############################################################################
#キャッシュ管理
###############################################################################

_DEFINE_ :_IMAGE_REGIST_ do |path|
  ImageControl.cache.regist(path, true)
end

_DEFINE_ :_IMAGE_DISPOSE_ do |path|
  ImageControl.cache.force_dispose(path)
end
