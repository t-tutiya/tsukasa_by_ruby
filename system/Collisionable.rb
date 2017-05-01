
#! ruby -E utf-8

###############################################################################
#TSUKASA for DXRuby ver2.2(2017/2/14)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
#
#Copyright (c) <2013-2017> <tsukasa TSUCHIYA>
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

require_relative './Layoutable.rb'

module Tsukasa

module Collisionable
  include Layoutable

  #DXRuby::Sprite
  attr_reader :collision_sprite

  #コリジョンの配列
  attr_reader :shape
  def shape=(arg)
    @shape = arg
    @collision_sprite.collision = @shape
  end

  def check_imple(condition, value)
    case condition
    when :collision_target
      @collision_sprite === find_control(value).collision_sprite
    when :not_collision_target
      not (@collision_sprite === find_control(value).collision_sprite)
    else
      super
    end
  end

  def initialize( system, 
                  _INPUT_API_: DXRuby::Input,
                  _SPRITE_API_: DXRuby::Sprite,
                  **options, 
                  &block)
    #ベースクラス
    @_INPUT_API_ = _INPUT_API_

    #コリジョン形状の指定
    @shape = options[:shape] || [0,0, options[:width], options[:height]]

    #コントロールSprite初期化
    @collision_sprite = _SPRITE_API_.new
    @collision_sprite.collision = @shape

    super

    #コリジョン図形の位置を補正
    @collision_sprite.x = @x
    @collision_sprite.y = @y
  end
  
  def update(absolute_x, absolute_y)
    @collision_sprite.x = @x
    @collision_sprite.y = @y
    super
  end
  
end

end

module Tsukasa

class CollisionableLayout < Layout
  include Collisionable
end

end
