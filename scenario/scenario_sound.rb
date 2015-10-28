#! ruby -E utf-8

###############################################################################
#TSUKASA for DXRuby α１
#汎用ゲームエンジン「司（TSUKASA）」 for DXRuby
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

#動作しない。tksからコンバートが必要
raise

キーを押してしばらくお待ちください。

@	_CREATE_ :SoundControl, file_path: "./test/bell.wav", id: :test01
初期化が終了しました。キーを押すと再生します

@	test01{_SET_ play: true}

再生中。スペースキーを押すと停止します。

@	test01{_SET_ play: false}

停止。次は無限ループ

@	test01{
@		_SET_ loop_count: -1
@		_SET_ play: true
@	}

無限ループ中。スペースキーを押すと停止します。

@	test01{_SET_ play: false}

停止。次はフェードイン

@	test01{
@		_MOVE_ 180, volume: [0,230]
@		_SET_ play: true
@	}

フェードインしつつ無限ループ中
スペースキーを押すとフェードアウトします

@	test01{
@		_SET_ play: false
@		_MOVE_ 180, volume: [230, 0]
@		_SET_ play: true
@	}

フェードアウトしつつ無限ループ中。スペースキーを押すと停止します

@	test01{_SET_ play: false}
