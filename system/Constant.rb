#! ruby -E utf-8
# coding: utf-8

###############################################################################
#TSUKASA for DXRuby ver1.2.1(2016/5/2)
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

module Tsukasa

  #
  #キーコード定数
  #
  
  #*1 日本で使われている標準的な109キーボードに存在しないキーです。
  #*2 テンキー(Numpad)にあるキーではなくメインキーボード側のキーです。
  #*3 メインキーボードにあるキーではなくテンキー(Numpad)にあるキーです。

  K_ESCAPE = DXRuby::K_ESCAPE # Esc
  K_1 = DXRuby::K_1 # 1
  K_2 = DXRuby::K_2 # 2
  K_3 = DXRuby::K_3 # 3
  K_4 = DXRuby::K_4 # 4
  K_5 = DXRuby::K_5 # 5
  K_6 = DXRuby::K_6 # 6
  K_7 = DXRuby::K_7 # 7
  K_8 = DXRuby::K_8 # 8
  K_9 = DXRuby::K_9 # 9
  K_0 = DXRuby::K_0 # 0
  K_MINUS = DXRuby::K_MINUS # - *2
  K_EQUALS = DXRuby::K_EQUALS	# = *1
  K_BACK = DXRuby::K_BACK # Backspace
  K_TAB = DXRuby::K_TAB # Tab
  K_Q = DXRuby::K_Q # Q
  K_W = DXRuby::K_W # W
  K_E = DXRuby::K_E # E
  K_R = DXRuby::K_R # R
  K_T = DXRuby::K_T # T
  K_Y = DXRuby::K_Y # Y
  K_U = DXRuby::K_U # U
  K_I = DXRuby::K_I # I
  K_O = DXRuby::K_O # O
  K_P = DXRuby::K_P # P
  K_LBRACKET = DXRuby::K_LBRACKET # [
  K_RBRACKET = DXRuby::K_RBRACKET # ]
  K_RETURN = DXRuby::K_RETURN # Enter
  K_LCONTROL = DXRuby::K_LCONTROL # 左Ctrl
  K_A = DXRuby::K_A # A
  K_S = DXRuby::K_S # S
  K_D = DXRuby::K_D # D
  K_F = DXRuby::K_F # F
  K_G = DXRuby::K_G # G
  K_H = DXRuby::K_H # H
  K_J = DXRuby::K_J # J
  K_K = DXRuby::K_K # K
  K_L = DXRuby::K_L # L
  K_SEMICOLON = DXRuby::K_SEMICOLON # ;
  K_APOSTROPHE = DXRuby::K_APOSTROPHE # ' *1
  K_GRAVE = DXRuby::K_GRAVE # ` *1
  K_LSHIFT = DXRuby::K_LSHIFT # 左Shift
  K_BACKSLASH = DXRuby::K_BACKSLASH # \
  K_Z = DXRuby::K_Z # Z
  K_X = DXRuby::K_X # X
  K_C = DXRuby::K_C # C
  K_V = DXRuby::K_V # V
  K_B = DXRuby::K_B # B
  K_N = DXRuby::K_N # N
  K_M = DXRuby::K_M # M
  K_COMMA = DXRuby::K_COMMA # ,
  K_PERIOD = DXRuby::K_PERIOD # .
  K_SLASH = DXRuby::K_SLASH # / *2
  K_RSHIFT = DXRuby::K_RSHIFT # 右Shift
  K_MULTIPLY = DXRuby::K_MULTIPLY # * *3
  K_LMENU = DXRuby::K_LMENU # 左Alt
  K_SPACE = DXRuby::K_SPACE # Space
  K_CAPITAL = DXRuby::K_CAPITAL # Caps Lock
  K_F1 = DXRuby::K_F1 # F1
  K_F2 = DXRuby::K_F2 # F2
  K_F3 = DXRuby::K_F3 # F3
  K_F4 = DXRuby::K_F4 # F4
  K_F5 = DXRuby::K_F5 # F5
  K_F6 = DXRuby::K_F6 # F6
  K_F7 = DXRuby::K_F7 # F7
  K_F8 = DXRuby::K_F8 # F8
  K_F9 = DXRuby::K_F9 # F9
  K_F10 = DXRuby::K_F10 # F10
  K_NUMLOCK = DXRuby::K_NUMLOCK # NumLock *3
  K_SCROLL = DXRuby::K_SCROLL # ScrollLock
  K_NUMPAD7 = DXRuby::K_NUMPAD7 # 7 *3
  K_NUMPAD8 = DXRuby::K_NUMPAD8 # 8 *3
  K_NUMPAD9 = DXRuby::K_NUMPAD9 # 9 *3
  K_SUBTRACT = DXRuby::K_SUBTRACT # - *3
  K_NUMPAD4 = DXRuby::K_NUMPAD4 # 4 *3
  K_NUMPAD5 = DXRuby::K_NUMPAD5 # 5 *3
  K_NUMPAD6 = DXRuby::K_NUMPAD6 # 6 *3
  K_ADD = DXRuby::K_ADD # + *3
  K_NUMPAD1 = DXRuby::K_NUMPAD1 # 1 *3
  K_NUMPAD2 = DXRuby::K_NUMPAD2 # 2 *3
  K_NUMPAD3 = DXRuby::K_NUMPAD3 # 3 *3
  K_NUMPAD0 = DXRuby::K_NUMPAD0 # 0 *3
  K_DECIMAL = DXRuby::K_DECIMAL # . *3
  K_OEM_102 = DXRuby::K_OEM_102 # 不明
  K_F11 = DXRuby::K_F11 # F11
  K_F12 = DXRuby::K_F12 # F12
  K_F13 = DXRuby::K_F13 # F13 *1
  K_F14 = DXRuby::K_F14 # F14 *1
  K_F15 = DXRuby::K_F15 # F15 *1
  K_KANA = DXRuby::K_KANA # カタカナひらがな
  K_ABNT_C1 = DXRuby::K_ABNT_C1 # 不明
  K_CONVERT = DXRuby::K_CONVERT # 変換
  K_NOCONVERT = DXRuby::K_NOCONVERT # 無変換
  K_YEN = DXRuby::K_YEN # ￥
  K_ABNT_C2 = DXRuby::K_ABNT_C2 # 不明
  K_NUMPADEQUALS = DXRuby::K_NUMPADEQUALS	# = *3 *1
  K_PREVTRACK = DXRuby::K_PREVTRACK # ^
  K_AT = DXRuby::K_AT # @
  K_COLON = DXRuby::K_COLON # :
  K_UNDERLINE = DXRuby::K_UNDERLINE # _ *1
  K_KANJI = DXRuby::K_KANJI # 半角/全角
  K_STOP = DXRuby::K_STOP # 不明
  K_AX = DXRuby::K_AX # 不明
  K_UNLABELED = DXRuby::K_UNLABELED # 不明
  K_NEXTTRACK = DXRuby::K_NEXTTRACK # 不明
  K_NUMPADENTER = DXRuby::K_NUMPADENTER # Enter *3
  K_RCONTROL = DXRuby::K_RCONTROL # 右Ctrl
  K_MUTE = DXRuby::K_MUTE # 不明
  K_CALCULATOR = DXRuby::K_CALCULATOR # 不明
  K_PLAYPAUSE = DXRuby::K_PLAYPAUSE # 不明
  K_MEDIASTOP = DXRuby::K_MEDIASTOP # 不明
  K_VOLUMEDOWN = DXRuby::K_VOLUMEDOWN # 不明
  K_VOLUMEUP = DXRuby::K_VOLUMEUP # 不明
  K_WEBHOME = DXRuby::K_WEBHOME # 不明
  K_NUMPADCOMMA = DXRuby::K_NUMPADCOMMA # , *3 *1
  K_DIVIDE = DXRuby::K_DIVIDE # / *3
  K_SYSRQ = DXRuby::K_SYSRQ # 不明
  K_RMENU = DXRuby::K_RMENU # 右Alt
  K_PAUSE = DXRuby::K_PAUSE # PauseBreak
  K_HOME = DXRuby::K_HOME # Home
  K_UP = DXRuby::K_UP # ↑
  K_PRIOR = DXRuby::K_PRIOR # 不明
  K_LEFT = DXRuby::K_LEFT # ←
  K_RIGHT = DXRuby::K_RIGHT # →
  K_END = DXRuby::K_END # End
  K_DOWN = DXRuby::K_DOWN # ↓
  K_NEXT = DXRuby::K_NEXT # 不明
  K_INSERT = DXRuby::K_INSERT # Insert
  K_DELETE = DXRuby::K_DELETE # Delete
  K_LWIN = DXRuby::K_LWIN # 左Windows
  K_RWIN = DXRuby::K_RWIN # 右Windows
  K_APPS = DXRuby::K_APPS # アプリケーション
  K_POWER = DXRuby::K_POWER # 不明
  K_SLEEP = DXRuby::K_SLEEP # 不明
  K_WAKE = DXRuby::K_WAKE # 不明
  K_WEBSEARCH = DXRuby::K_WEBSEARCH # 不明
  K_WEBFAVORITES = DXRuby::K_WEBFAVORITES # 不明
  K_WEBREFRESH = DXRuby::K_WEBREFRESH # 不明
  K_WEBSTOP = DXRuby::K_WEBSTOP # 不明
  K_WEBFORWARD = DXRuby::K_WEBFORWARD # 不明
  K_WEBBACK = DXRuby::K_WEBBACK # 不明
  K_MYCOMPUTER = DXRuby::K_MYCOMPUTER # 不明
  K_MAIL = DXRuby::K_MAIL # 不明
  K_MEDIASELECT = DXRuby::K_MEDIASELECT # 不明
  K_BACKSPACE = DXRuby::K_BACKSPACE # Backspace
  K_NUMPADSTAR = DXRuby::K_NUMPADSTAR # * *3
  K_LALT = DXRuby::K_LALT # 左Alt
  K_CAPSLOCK = DXRuby::K_CAPSLOCK # CapsLock
  K_NUMPADMINUS = DXRuby::K_NUMPADMINUS # - *3
  K_NUMPADPLUS = DXRuby::K_NUMPADPLUS # + *3
  K_NUMPADPERIOD = DXRuby::K_NUMPADPERIOD # . *3
  K_NUMPADSLASH = DXRuby::K_NUMPADSLASH # / *3
  K_RALT = DXRuby::K_RALT # 右Alt
  K_UPARROW = DXRuby::K_UPARROW # ↑
  K_PGUP = DXRuby::K_PGUP # PageUp
  K_LEFTARROW = DXRuby::K_LEFTARROW # ←
  K_RIGHTARROW = DXRuby::K_RIGHTARROW # →
  K_DOWNARROW = DXRuby::K_DOWNARROW # ↓
  K_PGDN = DXRuby::K_PGDN # PageDown

  #
  #マウスボタン定数
  #

  M_LBUTTON	= DXRuby::M_LBUTTON #左ボタン
  M_MBUTTON	= DXRuby::M_MBUTTON #中ボタン
  M_RBUTTON	= DXRuby::M_RBUTTON #右ボタン

  #
  #パッド定数
  #

  P_UP	= DXRuby::P_UP
  P_LEFT	= DXRuby::P_LEFT
  P_RIGHT	= DXRuby::P_RIGHT
  P_DOWN	= DXRuby::P_DOWN
  P_BUTTON0	= DXRuby::P_BUTTON0
  P_BUTTON1	= DXRuby::P_BUTTON1
  P_BUTTON2	= DXRuby::P_BUTTON2
  P_BUTTON3	= DXRuby::P_BUTTON3
  P_BUTTON4	= DXRuby::P_BUTTON4
  P_BUTTON5	= DXRuby::P_BUTTON5
  P_BUTTON6	= DXRuby::P_BUTTON6
  P_BUTTON7	= DXRuby::P_BUTTON7
  P_BUTTON8	= DXRuby::P_BUTTON8
  P_BUTTON9	= DXRuby::P_BUTTON9
  P_BUTTON10	= DXRuby::P_BUTTON10
  P_BUTTON11	= DXRuby::P_BUTTON11
  P_BUTTON12	= DXRuby::P_BUTTON12
  P_BUTTON13	= DXRuby::P_BUTTON13
  P_BUTTON14	= DXRuby::P_BUTTON14
  P_BUTTON15	= DXRuby::P_BUTTON15
  #アナログ左スティックのデジタル入力
  P_L_UP	= DXRuby::P_L_UP
  P_L_LEFT	= DXRuby::P_L_LEFT
  P_L_RIGHT	= DXRuby::P_L_RIGHT
  P_L_DOWN	= DXRuby::P_L_DOWN
  #アナログ右スティックのデジタル入力
  P_R_UP	= DXRuby::P_R_UP
  P_R_LEFT	= DXRuby::P_R_LEFT
  P_R_RIGHT	= DXRuby::P_R_RIGHT
  P_R_DOWN	= DXRuby::P_R_DOWN
  #アナログPOVのデジタル入力
  P_D_UP	= DXRuby::P_D_UP
  P_D_LEFT	= DXRuby::P_D_LEFT
  P_D_RIGHT	= DXRuby::P_D_RIGHT
  P_D_DOWN	= DXRuby::P_D_DOWN

  #
  #マウスカーソル定数
  #

  IDC_APPSTARTING	= DXRuby::IDC_APPSTARTING #標準の矢印カーソルと小さい砂時計カーソル
  IDC_ARROW	= DXRuby::IDC_ARROW #標準の矢印カーソル
  IDC_CROSS	= DXRuby::IDC_CROSS #十字カーソル
  IDC_HAND	= DXRuby::IDC_HAND #ハンドカーソル
  IDC_HELP	= DXRuby::IDC_HELP #矢印と疑問符
  IDC_IBEAM	= DXRuby::IDC_IBEAM #アイビーム（ 縦線）カーソル
  IDC_NO	= DXRuby::IDC_NO #禁止カーソル（ 円に左上から右下への斜線）
  IDC_SIZEALL	= DXRuby::IDC_SIZEALL #4 方向の矢印カーソル
  IDC_SIZENESW	= DXRuby::IDC_SIZENESW #右上と左下を指す両方向矢印カーソル
  IDC_SIZENS	= DXRuby::IDC_SIZENS #上下を指す両方向矢印カーソル
  IDC_SIZENWSE	= DXRuby::IDC_SIZENWSE #左上と右下を指す両方向矢印カーソル
  IDC_SIZEWE	= DXRuby::IDC_SIZEWE #左右を指す両方向矢印カーソル
  IDC_UPARROW	= DXRuby::IDC_UPARROW #上を指す垂直の矢印カーソル
  IDC_WAIT	= DXRuby::IDC_WAIT #砂時計カーソル

  #
  #色定数
  #

  C_BLACK = DXRuby::C_BLACK
  C_RED = DXRuby::C_RED
  C_GREEN = DXRuby::C_GREEN
  C_BLUE = DXRuby::C_BLUE
  C_YELLOW = DXRuby::C_YELLOW
  C_CYAN = DXRuby::C_CYAN
  C_MAGENTA = DXRuby::C_MAGENTA
  C_WHITE = DXRuby::C_WHITE
  C_DEFAULT = DXRuby::C_DEFAULT #[0, 0, 0, 0]
end