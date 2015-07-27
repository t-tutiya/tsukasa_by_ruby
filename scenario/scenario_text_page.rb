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

define :page_icon do |options|

  create :LayoutControl, 
          :x_pos => options[:x_pos], 
          :y_pos => options[:y_pos], 
          :width => 24,
          :height => 24 do

    image :file_path=>"./sozai/line_icon/line_icon_1.png", 
        :id=>1, :visible => false
    image :file_path=>"./sozai/line_icon/line_icon_2.png", 
        :id=>2, :visible => false
    image :file_path=>"./sozai/line_icon/line_icon_3.png", 
        :id=>3, :visible => false
    image :file_path=>"./sozai/line_icon/line_icon_4.png", 
        :id=>4, :visible => false
    image :file_path=>"./sozai/line_icon/line_icon_5.png", 
        :id=>5, :visible => false
    image :file_path=>"./sozai/line_icon/line_icon_6.png", 
        :id=>6, :visible => false
    image :file_path=>"./sozai/line_icon/line_icon_7.png", 
        :id=>7, :visible => false
    image :file_path=>"./sozai/line_icon/line_icon_8.png", 
        :id=>8, :visible => false
    _WHILE_ ->{true} do
      set 8, visible: false
      set 1, visible: true
    	wait [:count], count: 5
      set 1, visible: false
      set 2, visible: true
    	wait [:count], count: 5
      set 2, visible: false
      set 3, visible: true
    	wait [:count], count: 5
      set 3, visible: false
      set 4, visible: true
    	wait [:count], count: 5
      set 4, visible: false
      set 5, visible: true
    	wait [:count], count: 5
      set 5, visible: false
      set 6, visible: true
    	wait [:count], count: 5
      set 6, visible: false
      set 7, visible: true
    	wait [:count], count: 30
      set 7, visible: false
      set 8, visible: true
    	wait [:count], count: 15
    end
  end

end

page_icon x_pos: 100, y_pos: 100
page_icon x_pos: 200, y_pos: 200
page_icon x_pos: 300, y_pos: 300



create :LayoutControl, x_pos: 0, y_pos: 0, x_count: 4, ycount: 1 do
  create :ImageTilesContainer, :file_path=>"./sozai/icon_4_a.png", :id=>:test
  _WHILE_ ->{true} do
    set 3, visible: false
    set 0, visible: true
    wait [:count], count: 5
    set 0, visible: false
    set 1, visible: true
    wait [:count], count: 5
    set 1, visible: false
    set 2, visible: true
    wait [:count], count: 5
    set 2, visible: false
    set 3, visible: true
    wait [:count], count: 5
  end
end
