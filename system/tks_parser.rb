#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby  α１
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

# Usage:
# gem install parslet するか、
# bundler で Gemfile に gem 'parslet' を書いて
# bundle install して bundle exec で利用してください
require 'parslet'

class TKSParser < Parslet::Parser

  attr_accessor :script_prefix, :comment_str
  attr_accessor :inline_command_open, :inline_command_close
  attr_reader :indent_mode, :indent_width

  def initialize(
    indent_mode: :spaces, #インデントモード
    indent_width: 2, #インデントの空白文字数単位
    script_prefix: "@", #スクリプト行接頭字
    comment_str: "//", #コメント行接頭字
    inline_command_open: "[", #インラインコマンドプレフィクス
    inline_command_close: "]" #インラインコマンドポストフィクス
  )
    super()
    @indent_mode = indent_mode
    @indent_width = indent_width
    @script_prefix = script_prefix
    @comment_str = comment_str
    @inline_command_open = inline_command_open
    @inline_command_close = inline_command_close
  end

  def indent_mode=(indent_mode)
    @indent_mode = indent_mode
    @indent_char = nil
  end

  def indent_width=(indent_width)
    @indent_width = indent_width
    @indent_char = nil
  end

  #インデント対象
  def indent_char
    @indent_char ||= case @indent_mode
    when :tab
      "\t" #タブ
    when :spaces
      " " * @indent_width #指定した文字数の空白
    end
  end

  #インデント
  rule(:indent) { str(indent_char) }
  
  #改行
  rule(:newline) { str("\n") }

  #コマンドブロック
  rule(:command) {
    (str(script_prefix) | indent) >>
    match['^\n'].repeat(1).as(:command) >>
    newline.maybe
  }

  #textコマンドブロック
  rule(:printable) {
    (
      (inline_command | text).repeat(1).as(:printable) >>
      newline.maybe.as(:line_feed) >>
      blankline.repeat.as(:blanklines)
    )
  }

  #文字（か？）
  #TODO：インラインコマンドプレフィクスをハードコーディングしたらいかんのでは
  rule(:text) { match['^\[\n'].repeat(1).as(:text) }

  #インラインコマンド
  rule(:inline_command) {
    str(inline_command_open) >>
    (str('\\') >> any | str(inline_command_close).absent? >> any).repeat.as(:inline_command) >>
    str(inline_command_close)
  }

  #コメント
  rule(:comment) {
    str(comment_str) >> match[' \t'].repeat >> match['^\n'].repeat.as(:comment)
  }

  #空行（テキストウィンドウの改ページの明示）
  rule(:blankline) { (match[' \t'].repeat >> newline) }

  rule(:node) { blankline.maybe >> (comment | command | printable) }

  rule(:document) { (blankline | node).repeat }

  root :document

  class Replacer < Parslet::Transform
    #コメント行→無視
    rule(:comment => simple(:comment)) { [] }

    #テキスト行→textコマンド
    rule(:text => simple(:string)) { %Q'text "#{string}"' }

    #コマンドブロック→そのまま返す
    rule(:command => simple(:command)) { [command.to_s] }

    #インラインコマンド→そのまま返す
    rule(:inline_command => simple(:command)) { command.to_s }

    #textブロック→そのまま返す（？）
    rule(
      :printable => sequence(:commands),
      :line_feed => nil,
      :blanklines => []
    ) { commands }

    #textブロック＋改行→改行コマンド追加
    rule(
      :printable => sequence(:commands),
      :line_feed => simple(:line_feed),
      :blanklines => []
    ) { commands + ["line_feed"] }

    #textブロック＋改行＋空行→改行＋キー入力待ちコマンド追加追加
    rule(
      :printable => sequence(:commands),
      :line_feed => simple(:line_feed),
      :blanklines => simple(:blanklines)
    ) { commands + ["line_feed", "pause"] }
  end

end
