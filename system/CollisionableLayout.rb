
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

require_relative './Layout.rb'

module Tsukasa

module Collisionable
  include Layoutable

  #DXRuby::Sprite
  attr_reader :collision_sprite

  #コリジョンの配列指定
  #[x, y]                    1ピクセルの点
  #[x, y, r]                 中心(x, y)から半径rのサイズの円
  #[x1, y1, x2, y2]          左上(x1, y1)と右下(x2, y2)を結ぶ矩形
  #[x1, y1, x2, y2, x3, y3]  (x1, y1)～(x2, y2)～(x3, y3)を結ぶ三角形
  def shape=(arg)
    @collision_sprite.collision = arg
  end
  def shape()
    @collision_sprite.collision
  end

  #横の拡大率 
  #Float (初期値： 1.0)
  def scale_x=(arg)
    @collision_sprite.scale_x = arg
  end
  def scale_x()
    @collision_sprite.scale_x
  end

  #縦の拡大率  
  #Float (初期値： 1.0)
  def scale_y=(arg)
    @collision_sprite.scale_y = arg
  end
  def scale_y()
    @collision_sprite.scale_y
  end

  #回転、拡大の中心X座標。
  #Integer (初期値： 0)
  def center_x=(arg)
    @collision_sprite.center_x = arg
  end
  def center_x()
    @collision_sprite.center_x
  end

  #回転、拡大の中心Y座標。
  #Integer (初期値： 0)
  def center_y=(arg)
    @collision_sprite.center_y = arg
  end
  def center_y()
    @collision_sprite.center_y
  end


  #360度系で画像の回転角度を指定します。
  #Float (初期値： 0.0)
  def angle=(arg)
    @collision_sprite.angle = arg
  end
  def angle()
    @collision_sprite.angle
  end

  #衝突判定の有効、無効を変更します。
  #bool (初期値： true)
  def collision_enable=(arg)
    @collision_sprite.collision_enable = arg
  end
  def angle()
    @collision_sprite.collision_enable
  end

  #衝突判定範囲に回転/スケーリングを加味する場合に真を返します。
  #bool (初期値： true)
  def collision_sync=(arg)
    @collision_sprite.collision_sync = arg
  end
  def angle()
    @collision_sprite.collision_sync
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
                  shape:, 
                  scale_x: 1.0,
                  scale_y: 1.0,
                  center_x: 0,
                  center_y: 0,
                  angle: 0.0,
                  collision_enable: true,
                  collision_sync: true,
                  **options, 
                  &block)
    #ベースクラス
    @_INPUT_API_ = _INPUT_API_

    #コントロールSprite初期化
    @collision_sprite = _SPRITE_API_.new
    self.shape = shape

    #アフィン変換系初期化
    self.scale_x = scale_x
    self.scale_y = scale_y
    self.center_x = center_x
    self.center_y = center_y
    self.angle = angle
    
    #フラグ初期化
    self.collision_enable = collision_enable
    self.collision_sync = collision_sync

    #コリジョン図形の位置を補正
    @collision_sprite.x = 0
    @collision_sprite.y = 0

    super
  end
  
  def update(absolute_x, absolute_y)
    @collision_sprite.x = absolute_x + @x
    @collision_sprite.y = absolute_y + @y

    super
  end
  
end

end

module Tsukasa

class CollisionableLayout < Layout
  include Collisionable
end

end
