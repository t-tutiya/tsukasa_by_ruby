#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver2.1(2016/12/23)
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
#計測関連
###############################################################################

#アプリを起動してからのミリ秒を取得する
_DEFINE_ :_RUNNING_TIME_ do 
  _YIELD_ time: DXRuby::Window.running_time
end

#FPSカウンタ（取得／設定）
_DEFINE_ :_FPS_ do |_ARGUMENT_: false|
  DXRuby::Window.fps = _ARGUMENT_ if _ARGUMENT_
  _CHECK_BLOCK_ do
    _YIELD_ fps: DXRuby::Window.real_fps
  end
end

###############################################################################
#ウィンドウ管理
###############################################################################

#フルスクリーン化可能な解像度のリストを取得する
_DEFINE_ :_SCREEN_MODES_ do 
  _YIELD_ screen_modes: DXRuby::Window.get_screen_modes
end

#フルスクリーンのオンオフ
_DEFINE_ :_FULL_SCREEN_ do |_ARGUMENT_:|
  DXRuby::Window.full_screen = _ARGUMENT_ #bool
end

#スクリーンショットキャプチャ
_DEFINE_ :_CAPTURE_SS_ do |path, options|
  DXRuby::Window.get_screen_shot(path, options[:format] || DXRuby::FORMAT_PNG)
end

###############################################################################
#ファイルダイアログ管理
###############################################################################

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

###############################################################################
#マウス／ゲームパッド管理
###############################################################################

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

###############################################################################
#フォント管理
###############################################################################

#一時truetypeフォントの登録
_DEFINE_ :_INSTALL_FONT_ do |_ARGUMENT_:|
  Char.install(_ARGUMENT_)
end

#プリレンダフォントデータの登録
_DEFINE_ :_INSTALL_PRERENDER_FONT_ do |_ARGUMENT_:, font_name:| 
  Char.install_prerender(font_name, _ARGUMENT_)
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

###############################################################################
#セーブロード管理
###############################################################################

#_SYSTEM_コントロールを保存する
#※保存されるのは次フレームなので注意
_DEFINE_ :_SYSTEM_SAVE_ do |_ARGUMENT_:|
  _SEND_ [:_ROOT_, :_SYSTEM_] do
    _SERIALIZE_ do |command_list:|
      db = PStore.new(_ARGUMENT_)
      db.transaction do
        db["key"] = command_list
      end
    end
  end
end

#_SYSTEM_コントロールに読み込む
#※保存されるのは次フレームなので注意
_DEFINE_ :_SYSTEM_LOAD_ do |_ARGUMENT_:|
  _SEND_ [:_ROOT_, :_SYSTEM_] do
    db = PStore.new(_ARGUMENT_)
    command_list = nil
    db.transaction do
      command_list = db["key"]
    end
    _SERIALIZE_ command_list
  end
end

#_LOCAL_コントロールを保存する
#※保存されるのは次フレームなので注意
_DEFINE_ :_LOCAL_SAVE_ do |_ARGUMENT_:|
  _SEND_ [:_ROOT_, :_LOCAL_] do
    _SERIALIZE_ do |command_list:|
      db = PStore.new(_ARGUMENT_)
      db.transaction do
        db["key"] = command_list
      end
    end
  end
end

#_LOCAL_コントロールを読み込む
#※保存されるのは次フレームなので注意
_DEFINE_ :_LOCAL_LOAD_ do |_ARGUMENT_:|
  _SEND_ [:_ROOT_, :_LOCAL_] do
    db = PStore.new(_ARGUMENT_)
    command_list = nil
    db.transaction do
      command_list = db["key"]
    end
    _SERIALIZE_ command_list
  end
end

#コントロールツリーを保存する
_DEFINE_ :_QUICK_SAVE_ do |_ARGUMENT_:|
  _SERIALIZE_ do |command_list:|
    db = PStore.new(_ARGUMENT_)
    db.transaction do
      db["key"] = command_list
    end
  end
end

#コントロールツリーを読み込む
_DEFINE_ :_QUICK_LOAD_ do |_ARGUMENT_:|
  db = PStore.new(_ARGUMENT_)
  command_list = nil
  db.transaction do
    command_list = db["key"]
  end
  _SERIALIZE_ command_list
end

