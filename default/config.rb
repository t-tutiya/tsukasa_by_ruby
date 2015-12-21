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

#デバッグモード管理フラグ（現在未使用）
_SET_ :_SYSTEM_, _DEBUG_: false

#セーブデータの保存フォルダ
_SET_ :_SYSTEM_, _SAVE_DATA_PATH_: "./data/"

#システムデータのファイル名
_SET_ :_SYSTEM_, _SYSTEM_FILENAME_: "system_data.bin"

#ローカルデータのファイル名
_SET_ :_SYSTEM_, _LOCAL_FILENAME_: "_local_data.bin"

#一時データのファイル名
_SET_ :_SYSTEM_, _QUICK_DATA_FILENAME_: "_quick_data.bin"

#TextLayerデフォルトＩＤ
_SET_ :_DEFAULT_CONTROL_, TextLayer: :text0

#TextPageControlデフォルトＩＤ
_SET_ :_DEFAULT_CONTROL_, TextPageControl: :default_text_page_control0

#無名コントロールデフォルトＩＤ（未使用？）
_SET_ :_DEFAULT_CONTROL_, Anonymous: :anonymous
