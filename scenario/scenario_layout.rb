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

create :LayoutControl, 
        :x_pos => 600, 
        :y_pos => 150, 
        :width => 256,
        :height => 256 do
  image :file_path=>"./sozai/button_normal.png", float_mode: :right,
         :x_pos => 150,
         :y_pos => 150
  image :file_path=>"./sozai/button_normal.png", float_mode: :right#,
         #:x_pos => 100,
         #:y_pos => 100
  #image :file_path=>"./sozai/button_normal.png"
end
