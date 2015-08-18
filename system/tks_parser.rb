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
    indent_mode: :spaces, indent_width: 2,
    script_prefix: "@", comment_str: "//",
    inline_command_open: "[", inline_command_close: "]"
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

  def indent_char
    @indent_char ||= case @indent_mode
    when :tab
      "\t"
    when :spaces
      " " * @indent_width
    end
  end

  rule(:indent) { str(indent_char) }
  rule(:newline) { str("\n") }

  rule(:command) {
    (str(script_prefix) | indent) >>
    match['^\n'].repeat(1).as(:command) >>
    newline.maybe
  }

  rule(:printable) {
    (
      (inline_command | text).repeat(1).as(:printable) >>
      newline.maybe.as(:line_feed) >>
      blankline.repeat.as(:blanklines)
    )
  }

  rule(:text) { match['^\[\n'].repeat(1).as(:text) }

  rule(:inline_command) {
    str(inline_command_open) >>
    (str('\\') >> any | str(inline_command_close).absent? >> any).repeat.as(:inline_command) >>
    str(inline_command_close)
  }

  rule(:comment) {
    str(comment_str) >> match[' \t'].repeat >> match['^\n'].repeat.as(:comment)
  }

  rule(:blankline) { (match[' \t'].repeat >> newline) }
  rule(:node) { blankline.maybe >> (comment | command | printable) }
  rule(:document) { (blankline | node).repeat }

  root :document

  class Replacer < Parslet::Transform
    rule(:comment => simple(:comment)) { [] }
    rule(:text => simple(:string)) { %Q'text "#{string}"' }
    rule(:command => simple(:command)) { [command.to_s] }
    rule(:inline_command => simple(:command)) { command.to_s }
    rule(
      :printable => sequence(:commands),
      :line_feed => nil,
      :blanklines => []
    ) { commands }
    rule(
      :printable => sequence(:commands),
      :line_feed => simple(:line_feed),
      :blanklines => []
    ) { commands + ["line_feed"] }
    rule(
      :printable => sequence(:commands),
      :line_feed => simple(:line_feed),
      :blanklines => simple(:blanklines)
    ) { commands + ["line_feed", "pause"] }
  end

end
