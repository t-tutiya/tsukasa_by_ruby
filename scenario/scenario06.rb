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

create :ImageControl ,
       file_path: "./sozai/button_normal.png", x_pos: 100, y_pos: 100, 
       id: :BG1, float_mode: :right
create :ImageControl ,
       file_path: "./sozai/button_normal.png",
       id: :BG2, float_mode: :bottom
create :ImageControl ,
       file_path: "./sozai/button_normal.png",
       id: :BG3, float_mode: :none
=begin
create :ImageControl ,
       file_path: "./sozai/button_normal.png", 
       id: :BG2, join_right: true
create :ImageControl ,
       file_path: "./sozai/button_normal.png", 
       id: :BG3
=end
=begin
create :ImageControl ,
       file_path: "./sozai/button_normal.png", x_pos: 0, y_pos: 0, 
       id: :BG3
=end

pp "test1"
wait [:key_push]

set :BG1, x_pos: 200

next_frame
wait [:key_push]

set :BG2, x_pos: 200

next_frame
wait [:key_push]

set :BG3, x_pos: 200
