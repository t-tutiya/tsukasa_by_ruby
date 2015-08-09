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

create :LayoutControl, 
        :x_pos => 0, 
        :y_pos => 0, 
        :width => 256,
        :height => 256 do

  image :file_path=>"./sozai/button_normal.png", 
      :id=>0, :visible => true
  image :file_path=>"./sozai/button_over.png", 
      :id=>1, :visible => false
  image :file_path=>"./sozai/button_key_down.png", 
      :id=>2, :visible => false
  image :file_path=>"./sozai/button_out.png", 
      :id=>3, :visible => false
  _WHILE_ ->{true} do
      set target: 3, visible: false
      set target: 0, visible: true
  	wait [:count], count: 10
      set target: 0, visible: false
      set target: 1, visible: true
  	wait [:count], count: 10
      set target: 1, visible: false
      set target: 2, visible: true
  	wait [:count], count: 10
      set target: 2, visible: false
      set target: 3, visible: true
  	wait [:count], count: 10
  end
end
