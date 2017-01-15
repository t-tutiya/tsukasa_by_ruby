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
#ガベージコレクション関連（Rubyラッパー）
###############################################################################

#ガベージコレクション処理を強制的に実行する
_DEFINE_ :_GC_GARBAGE_COLLECT_ do |full_mark: true, immediate_sweep: true|
  GC.start(full_mark: full_mark, immediate_sweep: immediate_sweep)
end

#ガベージコレクションの実行を許可する
_DEFINE_ :_GC_ENABLE_ do
  GC.enable()
end

#ガベージコレクションの実行を禁止する
_DEFINE_ :_GC_DISABLE_ do
  GC.disable()
end

#ガベージコレクションの最新の情報をハッシュで取得する
#シンボルを設定した場合はその値のみを取得する
_DEFINE_ :_GC_LATEST_GC_INFO_ do |_ARGUMENT_: nil|
  if _ARGUMENT_
    _YIELD_({_ARGUMENT_ => GC.latest_gc_info(_ARGUMENT_)})
  else
    _YIELD_(GC.latest_gc_info())
  end
end

#ガベージコレクションの統計情報をハッシュで取得する
#シンボルを設定した場合はその値のみを取得する
_DEFINE_ :_GC_STATUS_ do |_ARGUMENT_: nil|
  if _ARGUMENT_
    _YIELD_({_ARGUMENT_ => GC.stat(_ARGUMENT_)})
  else
    _YIELD_(GC.stat())
  end
end

###############################################################################
#計測関連（DXRubyラッパー）
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
#ウィンドウ管理（DXRubyラッパー）
###############################################################################

#スクリーンショットキャプチャ
_DEFINE_ :_CAPTURE_SS_ do |path, options|
  DXRuby::Window.get_screen_shot(path, options[:format] || DXRuby::FORMAT_PNG)
end

###############################################################################
#ファイルダイアログ管理（DXRubyラッパー）
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
#マウス／ゲームパッド管理（DXRubyラッパー）
###############################################################################

#パッドのキーコンフィグを設定する
_DEFINE_ :_PAD_CONFIG_ do |pad_code:, key_code:, pad_number: 0|
  DXRuby::Input.set_config(pad_code, key_code, pad_number)
end

###############################################################################
#フォント管理（tsukasaラッパー）
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
#キャッシュ管理（tsukasaラッパー）
###############################################################################

_DEFINE_ :_IMAGE_REGIST_ do |_ARGUMENT_:|
  Image.cache.regist(_ARGUMENT_, true)
end

_DEFINE_ :_IMAGE_DISPOSE_ do |_ARGUMENT_:|
  Image.cache.force_dispose(_ARGUMENT_)
end
