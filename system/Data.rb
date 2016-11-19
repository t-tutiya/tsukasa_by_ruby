#! ruby -E utf-8

###############################################################################
#TSUKASA for DXRuby ver2.0(2016/8/28)
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

class Data < Control

  #ファイル保存先パス
  attr_accessor :folder_path
  #ファイルアクセスの許可設定
  attr_accessor :file_permission

  def initialize(options, yield_stack, root_control, parent_control, &block)
    @datastore = {}
    @folder_path = options[:folder_path] || "./"
    @file_permission = options[:file_permission] || true
    super
  end

  #データセーブ
  def _SAVE_(yield_stack, _ARGUMENT_:)
    raise unless @file_permission
    db = PStore.new(@folder_path + _ARGUMENT_)
    db.transaction do
      db["key"] = @datastore
    end
  end

  #データロード
  def _LOAD_(yield_stack, _ARGUMENT_:)
    raise unless @file_permission
    db = PStore.new(@folder_path + _ARGUMENT_)
    db.transaction do
      @datastore = db["key"]
    end
  end

  #上記以外の全てのメソッドアクセスをデータストアアクセスとみなす
  def method_missing(command_name, argument = nil)
    #ゲッター／セッター判定
    if command_name.to_s[-1] == '='
      #セッターの場合
      @datastore[command_name.to_s.chop!.to_sym] = argument
    else
      #ゲッターの場合
      return @datastore[command_name]
    end
  end

end

end
