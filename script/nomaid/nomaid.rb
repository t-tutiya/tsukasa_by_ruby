#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby ver1.0(2015/12/24)
#メッセージ指向ゲーム記述言語「司エンジン（Tsukasa Engine）」 for DXRuby
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

class NomaidControl < Control

  attr_accessor  :gold #所持金

  attr_accessor  :helth_point #生命力現在値
  attr_accessor  :helth_point_max #生命力
  attr_accessor  :mental_point #精神力現在値
  attr_accessor  :mental_point_max #精神力
  attr_accessor  :charm #魅力
  attr_accessor  :noble #気品
  attr_accessor  :culture #教養
  attr_accessor  :intelligence #知性
  attr_accessor  :allegiance #恭順
  attr_accessor  :courtesy #礼節

  def initialize(argument, options, yield_block_stack = [], block = nil, 
                  root_control)
    @debt = [1000, 2500, 5000, 10000, 25000, 50000, 100000]
    
    @gold = options[:gold] || 0

    @helth_point = options[:helth_point] || 100
    @helth_point_max = options[:helth_point_max] || 100
    @mental_point = options[:mental_point] || 100
    @mental_point_max = options[:mental_point_max] || 100
    @charm = options[:charm] || 1
    @noble = options[:noble] || 1
    @culture = options[:culture] || 1
    @intelligence = options[:intelligence] || 1
    @allegiance = options[:allegiance] || 1
    @courtesy = options[:courtesy] || 1
    
    super

    _TEMP_[:debt] = @debt

    _TEMP_[:week] = 0
    _TEMP_[:day] = 0
  end
  
  def lesson(argument, options, yield_block_stack)
    case _TEMP_[:flag]
    when :pray

      hp_cost = [
                  (@mental_point_max - @mental_point) + 15, 
                  [
                    @helth_point - (@mental_point_max - @mental_point + 15), 
                    @helth_point
                  ].max
                ].min
      mp_cost = [
                  10, 
                  [
                    @mental_point - 10, 
                    @mental_point
                  ].max
                ].min

      @allegiance +=  hp_cost / 2 + 
                      (mp_cost + @courtesy) / 3

      @noble += hp_cost / 2 + 
                (mp_cost + @intelligence) / 3

    when :academy

      hp_cost = [
                  (@mental_point_max - @mental_point) + 5, 
                  [
                    @helth_point - (@mental_point_max - @mental_point + 5), 
                    @helth_point
                  ].max
                ].min
      mp_cost = [
                  20, 
                  [
                    @mental_point - 20, 
                    @mental_point
                  ].max
                ].min

      @culture += hp_cost / 2 + 
                  (mp_cost + @intelligence) / 2

      @intelligence += (hp_cost + @allegiance) / 2 + 
                        mp_cost / 3

    when :dance

      hp_cost = [
                  (@mental_point_max - @mental_point) + 20, 
                  [
                    @helth_point - (@mental_point_max - @mental_point + 20), 
                    @helth_point
                  ].max
                ].min

      mp_cost = [
                  15, 
                  [
                    @mental_point - 15, 
                    @mental_point
                  ].max
                ].min

      @charm += (hp_cost + @courtesy) / 2 + 
                mp_cost / 2

      @noble += (hp_cost + @intelligence) / 2 + 
                mp_cost / 2

    when :courtesy

      hp_cost = [
                  (@mental_point_max - @mental_point) + 5, 
                  [
                    @helth_point - (@mental_point_max - @mental_point + 5), 
                    @helth_point
                  ].max
                ].min

      mp_cost = [
                  20, 
                  [
                    @mental_point - 20, 
                    @mental_point
                  ].max
                ].min

      @courtesy += hp_cost / 2 + 
                  (mp_cost + @culture) / 2

      @culture += (hp_cost + @allegiance) / 2 + 
                  mp_cost / 3
    end

    @helth_point -= hp_cost
    @mental_point -= mp_cost
  end

  def work(argument, options, yield_block_stack)
    case _TEMP_[:flag]
    when :cleaning
      hp_cost = [ @mental_point_max - @mental_point + 10, 
                  [ @helth_point - @mental_point_max - @mental_point + 10, 
                    @helth_point
                  ].max
                ].min

      mp_cost = [ 10, 
                  [ @mental_point - 10, 
                    @mental_point
                  ].max
                ].min

      reward = 200 + (hp_cost * @allegiance) / 2 + (mp_cost * @allegiance) / 2
      @allegiance += hp_cost / 3 + mp_cost / 3

    when :waitress

      hp_cost = [ @mental_point_max - @mental_point + 15, 
                  [ @helth_point - @mental_point_max - @mental_point + 15, 
                    @helth_point
                  ].max
                ].min

      mp_cost = [ 20, 
                  [ @mental_point - 20, 
                    @mental_point
                  ].max
                ].min

      reward = hp_cost * ((@allegiance + @courtesy + @intelligence / 2) / 3) + 
               mp_cost * ((@charm * 2 + @intelligence) / 3)

      @allegiance += hp_cost / 3 + mp_cost / 3

    when :tutor

      hp_cost = [ @mental_point_max - @mental_point + 25, 
                  [ @helth_point - @mental_point_max - @mental_point + 25, 
                    @helth_point
                  ].max
                ].min

      mp_cost = [ 40, 
                  [ @mental_point - 40, 
                    @mental_point
                  ].max
                ].min

      reward =  hp_cost * ((@noble + @courtesy + @intelligence / 2) / 3) + 
                mp_cost * ((@culture * 2 + @intelligence * 2) / 3)

    when :party

      hp_cost = [ @mental_point_max - @mental_point + 30, 
                  [ @helth_point - @mental_point_max - @mental_point + 30, 
                    @helth_point
                  ].max
                ].min

      mp_cost = [ 30, 
                  [ @mental_point - 30, 
                    @mental_point
                  ].max
                ].min

      reward =  hp_cost * ((@allegiance * 2 + @courtesy + @intelligence / 2) / 2) + 
                mp_cost * ((@culture / 2 + @charm * 2 + @noble * 2) / 3)

    end

    @helth_point -= hp_cost
    @mental_point -= mp_cost
    @gold += reward

    _TEMP_[:reward] = reward
  end

  def rest(argument, options, block_stack, yield_block_stack, block)
    @helth_point += [
                      100 - @helth_point, 
                      @mental_point
                    ].min

    @mental_point += [
                      100 - @mental_point, 
                      50
                     ].min
  end

  def week_init(argument, options, yield_block_stack)
    _TEMP_[:day] = 0
  end

  def day_init(argument, options, yield_block_stack)
    _TEMP_[:gold] = @gold

    _TEMP_[:helth_point] = @helth_point
    _TEMP_[:helth_point_max] = @helth_point_max
    _TEMP_[:mental_point] = @mental_point
    _TEMP_[:mental_point_max] = @mental_point_max
    _TEMP_[:charm] = @charm
    _TEMP_[:noble] = @noble
    _TEMP_[:culture] = @culture
    _TEMP_[:intelligence] = @intelligence
    _TEMP_[:allegiance] = @allegiance
    _TEMP_[:courtesy] = @courtesy

  end

  def end_day(argument, options, yield_block_stack)
    _TEMP_[:day] += 1
  end
  
  def end_week(argument, options, yield_block_stack)
    @gold -= @debt[_TEMP_[:week]]

    _TEMP_[:week] += 1

    if @gold < 0
      _TEMP_[:gameover] = true
    else
      _TEMP_[:gameover] = false
    end

    if _TEMP_[:week] == 7
      _TEMP_[:gameclear] = true
    end
  end
=begin
  def maid_debug(argument, options, block_stack, yield_block_stack, block)
    pp "所持金：#{@gold}  ＨＰ　：#{@helth_point}/#{@helth_point_max}  ＭＰ　：#{@mental_point}/#{@mental_point_max}"
    pp "魅力：#{@charm}  気品　：#{@noble}  教養　：#{@culture}"
    pp "知性：#{@intelligence}  恭順　：#{@allegiance}  礼節　：#{@courtesy}"
  end
=end
end
