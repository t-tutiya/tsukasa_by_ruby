#! ruby -E utf-8

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

require_relative './Control.rb'

module Tsukasa

class Data < Control
  #全てのメソッドアクセスをデータストアアクセスとみなす
  def method_missing(command_name, argument = nil)
    return unless command_name.to_s[-1] == '='

    command_name =  command_name.to_s.chop
    
    #インスタンス変数を動的に生成し、値を設定する
    instance_variable_set('@' + command_name, argument)
    
    #ゲッターメソッドを動的に生成する
    singleton_class.send( :define_method, 
                          command_name,
                          lambda{ 
                            instance_variable_get('@' + command_name) 
                          })
    
    #セッターメソッドを動的に生成する
    singleton_class.send( :define_method, 
                          command_name.to_s + '=', 
                          lambda{ |set_value| 
                            instance_variable_set('@' + command_name,set_value)
                          })
  end
end

end
