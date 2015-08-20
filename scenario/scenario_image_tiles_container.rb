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
_DEFINE_ :page_icon do |options|

  _CREATE_ :LayoutControl, 
          :x_pos => options[:x_pos], 
          :y_pos => options[:y_pos], 
          :width => 24,
          :height => 24 do
    _CREATE_ :ImageControl, :tiles => true, :file_path=>"./sozai/icon_8_a.png", :id=>:test, :x_count => 4, :y_count => 2
    _WHILE_ [:true] do
      set 7, visible: false
      set 0, visible: true
    	_WAIT_ [:count], count: 5
      set 0, visible: false
      set 1, visible: true
    	_WAIT_ [:count], count: 5
      set 1, visible: false
      set 2, visible: true
    	_WAIT_ [:count], count: 5
      set 2, visible: false
      set 3, visible: true
    	_WAIT_ [:count], count: 5
      set 3, visible: false
      set 4, visible: true
    	_WAIT_ [:count], count: 5
      set 4, visible: false
      set 5, visible: true
    	_WAIT_ [:count], count: 5
      set 5, visible: false
      set 6, visible: true
    	_WAIT_ [:count], count: 5
      set 6, visible: false
      set 7, visible: true
    	_WAIT_ [:count], count: 30
    end
  end
end

page_icon x_pos: 100, y_pos: 100
page_icon x_pos: 200, y_pos: 200
page_icon x_pos: 300, y_pos: 300

_CREATE_ :LayoutControl, x_pos: 0, y_pos: 0 do
  _CREATE_ :ImageControl, :tiles => true, :file_path=>"./sozai/icon_4_a.png", :id=>:test, :x_count => 4, :y_count => 1
  _WHILE_ [:true] do
    set 3, visible: false
    set 0, visible: true
    _WAIT_ [:count], count: 5
    set 0, visible: false
    set 1, visible: true
    _WAIT_ [:count], count: 5
    set 1, visible: false
    set 2, visible: true
    _WAIT_ [:count], count: 5
    set 2, visible: false
    set 3, visible: true
    _WAIT_ [:count], count: 5
  end
end
