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

#キーコード定数
K_ESCAPE	= DXRuby::K_ESCAPE
K_1	= DXRuby::K_1
K_2	= DXRuby::K_2
K_3	= DXRuby::K_3
K_4	= DXRuby::K_4
K_5	= DXRuby::K_5
K_6	= DXRuby::K_6
K_7	= DXRuby::K_7
K_8	= DXRuby::K_8
K_9	= DXRuby::K_9
K_0	= DXRuby::K_0
K_MINUS	= DXRuby::K_MINUS
K_EQUALS	= DXRuby::K_EQUALS
K_BACK	= DXRuby::K_BACK
K_TAB	= DXRuby::K_TAB
K_Q	= DXRuby::K_Q
K_W	= DXRuby::K_W
K_E	= DXRuby::K_E
K_R	= DXRuby::K_R
K_T	= DXRuby::K_T
K_Y	= DXRuby::K_Y
K_U	= DXRuby::K_U
K_I	= DXRuby::K_I
K_O	= DXRuby::K_O
K_P	= DXRuby::K_P
K_LBRACKET	= DXRuby::K_LBRACKET
K_RBRACKET	= DXRuby::K_RBRACKET
K_RETURN	= DXRuby::K_RETURN
K_LCONTROL	= DXRuby::K_LCONTROL
K_A	= DXRuby::K_A
K_S	= DXRuby::K_S
K_D	= DXRuby::K_D
K_F	= DXRuby::K_F
K_G	= DXRuby::K_G
K_H	= DXRuby::K_H
K_J	= DXRuby::K_J
K_K	= DXRuby::K_K
K_L	= DXRuby::K_L
K_SEMICOLON	= DXRuby::K_SEMICOLON
K_APOSTROPHE	= DXRuby::K_APOSTROPHE
K_GRAVE	= DXRuby::K_GRAVE
K_LSHIFT	= DXRuby::K_LSHIFT
K_BACKSLASH	= DXRuby::K_BACKSLASH
K_Z	= DXRuby::K_Z
K_X	= DXRuby::K_X
K_C	= DXRuby::K_C
K_V	= DXRuby::K_V
K_B	= DXRuby::K_B
K_N	= DXRuby::K_N
K_M	= DXRuby::K_M
K_COMMA	= DXRuby::K_COMMA
K_PERIOD	= DXRuby::K_PERIOD
K_SLASH	= DXRuby::K_SLASH
K_RSHIFT	= DXRuby::K_RSHIFT
K_MULTIPLY	= DXRuby::K_MULTIPLY
K_LMENU	= DXRuby::K_LMENU
K_SPACE	= DXRuby::K_SPACE
K_CAPITAL	= DXRuby::K_CAPITAL
K_F1	= DXRuby::K_F1
K_F2	= DXRuby::K_F2
K_F3	= DXRuby::K_F3
K_F4	= DXRuby::K_F4
K_F5	= DXRuby::K_F5
K_F6	= DXRuby::K_F6
K_F7	= DXRuby::K_F7
K_F8	= DXRuby::K_F8
K_F9	= DXRuby::K_F9
K_F10	= DXRuby::K_F10
K_NUMLOCK	= DXRuby::K_NUMLOCK
K_SCROLL	= DXRuby::K_SCROLL
K_NUMPAD7	= DXRuby::K_NUMPAD7
K_NUMPAD8	= DXRuby::K_NUMPAD8
K_NUMPAD9	= DXRuby::K_NUMPAD9
K_SUBTRACT	= DXRuby::K_SUBTRACT
K_NUMPAD4	= DXRuby::K_NUMPAD4
K_NUMPAD5	= DXRuby::K_NUMPAD5
K_NUMPAD6	= DXRuby::K_NUMPAD6
K_ADD	= DXRuby::K_ADD
K_NUMPAD1	= DXRuby::K_NUMPAD1
K_NUMPAD2	= DXRuby::K_NUMPAD2
K_NUMPAD3	= DXRuby::K_NUMPAD3
K_NUMPAD0	= DXRuby::K_NUMPAD0
K_DECIMAL	= DXRuby::K_DECIMAL
K_OEM_102	= DXRuby::K_OEM_102
K_F11	= DXRuby::K_F11
K_F12	= DXRuby::K_F12
K_F13	= DXRuby::K_F13
K_F14	= DXRuby::K_F14
K_F15	= DXRuby::K_F15
K_KANA	= DXRuby::K_KANA
K_ABNT_C1	= DXRuby::K_ABNT_C1
K_CONVERT	= DXRuby::K_CONVERT
K_NOCONVERT	= DXRuby::K_NOCONVERT
K_YEN	= DXRuby::K_YEN
K_ABNT_C2	= DXRuby::K_ABNT_C2
K_NUMPADEQUALS	= DXRuby::K_NUMPADEQUALS
K_PREVTRACK	= DXRuby::K_PREVTRACK
K_AT	= DXRuby::K_AT
K_COLON	= DXRuby::K_COLON
K_UNDERLINE	= DXRuby::K_UNDERLINE
K_KANJI	= DXRuby::K_KANJI
K_STOP	= DXRuby::K_STOP
K_AX	= DXRuby::K_AX
K_UNLABELED	= DXRuby::K_UNLABELED
K_NEXTTRACK	= DXRuby::K_NEXTTRACK
K_NUMPADENTER	= DXRuby::K_NUMPADENTER
K_RCONTROL	= DXRuby::K_RCONTROL
K_MUTE	= DXRuby::K_MUTE
K_CALCULATOR	= DXRuby::K_CALCULATOR
K_PLAYPAUSE	= DXRuby::K_PLAYPAUSE
K_MEDIASTOP	= DXRuby::K_MEDIASTOP
K_VOLUMEDOWN	= DXRuby::K_VOLUMEDOWN
K_VOLUMEUP	= DXRuby::K_VOLUMEUP
K_WEBHOME	= DXRuby::K_WEBHOME
K_NUMPADCOMMA	= DXRuby::K_NUMPADCOMMA
K_DIVIDE	= DXRuby::K_DIVIDE
K_SYSRQ	= DXRuby::K_SYSRQ
K_RMENU	= DXRuby::K_RMENU
K_PAUSE	= DXRuby::K_PAUSE
K_HOME	= DXRuby::K_HOME
K_UP	= DXRuby::K_UP
K_PRIOR	= DXRuby::K_PRIOR
K_LEFT	= DXRuby::K_LEFT
K_RIGHT	= DXRuby::K_RIGHT
K_END	= DXRuby::K_END
K_DOWN	= DXRuby::K_DOWN
K_NEXT	= DXRuby::K_NEXT
K_INSERT	= DXRuby::K_INSERT
K_DELETE	= DXRuby::K_DELETE
K_LWIN	= DXRuby::K_LWIN
K_RWIN	= DXRuby::K_RWIN
K_APPS	= DXRuby::K_APPS
K_POWER	= DXRuby::K_POWER
K_SLEEP	= DXRuby::K_SLEEP
K_WAKE	= DXRuby::K_WAKE
K_WEBSEARCH	= DXRuby::K_WEBSEARCH
K_WEBFAVORITES	= DXRuby::K_WEBFAVORITES
K_WEBREFRESH	= DXRuby::K_WEBREFRESH
K_WEBSTOP	= DXRuby::K_WEBSTOP
K_WEBFORWARD	= DXRuby::K_WEBFORWARD
K_WEBBACK	= DXRuby::K_WEBBACK
K_MYCOMPUTER	= DXRuby::K_MYCOMPUTER
K_MAIL	= DXRuby::K_MAIL
K_MEDIASELECT	= DXRuby::K_MEDIASELECT
K_BACKSPACE	= DXRuby::K_BACKSPACE
K_NUMPADSTAR	= DXRuby::K_NUMPADSTAR
K_LALT	= DXRuby::K_LALT
K_CAPSLOCK	= DXRuby::K_CAPSLOCK
K_NUMPADMINUS	= DXRuby::K_NUMPADMINUS
K_NUMPADPLUS	= DXRuby::K_NUMPADPLUS
K_NUMPADPERIOD	= DXRuby::K_NUMPADPERIOD
K_NUMPADSLASH	= DXRuby::K_NUMPADSLASH
K_RALT	= DXRuby::K_RALT
K_UPARROW	= DXRuby::K_UPARROW
K_PGUP	= DXRuby::K_PGUP
K_LEFTARROW	= DXRuby::K_LEFTARROW
K_RIGHTARROW	= DXRuby::K_RIGHTARROW
K_DOWNARROW	= DXRuby::K_DOWNARROW
K_PGDN	= DXRuby::K_PGDN

#マウスボタン定数

M_LBUTTON	= DXRuby::M_LBUTTON #左ボタン
M_MBUTTON	= DXRuby::M_MBUTTON #中ボタン
M_RBUTTON	= DXRuby::M_RBUTTON #右ボタン

#パッド定数

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
P_L_UP	= DXRuby::P_L_UP
P_L_LEFT	= DXRuby::P_L_LEFT
P_L_RIGHT	= DXRuby::P_L_RIGHT
P_L_DOWN	= DXRuby::P_L_DOWN
P_R_UP	= DXRuby::P_R_UP
P_R_LEFT	= DXRuby::P_R_LEFT
P_R_RIGHT	= DXRuby::P_R_RIGHT
P_R_DOWN	= DXRuby::P_R_DOWN
P_D_UP	= DXRuby::P_D_UP
P_D_LEFT	= DXRuby::P_D_LEFT
P_D_RIGHT	= DXRuby::P_D_RIGHT
P_D_DOWN	= DXRuby::P_D_DOWN

#マウスカーソル定数
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
