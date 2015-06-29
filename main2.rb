#! ruby -E utf-8

require 'dxruby'
require 'pp'
require './system/tsukasa.rb'

class ScriptCompiler
  impl_define :right, [:option]
end

class Test < ImageControl
  def command_right(options, target)
    @x_pos += 5
    options[:right] -= 1
    if options[:right] != 0
      return :continue, [:right, options]
    else
      return :continue, [:down, {:down => 50}]
    end
  end

  def command_down(options, target)
    @y_pos += 5
    options[:down] -= 1
    if options[:down] != 0
      return :continue, [:down, options]
    else
      return :continue, [:left, {:left => 50}]
    end
  end

  def command_left(options, target)
    @x_pos -= 5
    options[:left] -= 1
    if options[:left] != 0
      return :continue, [:left, options]
    else
      return :continue, [:up, {:up => 50}]
    end
  end

  def command_up(options, target)
    @y_pos -= 5
    options[:up] -= 1
    if options[:up] != 0
      return :continue, [:up, options]
    else
      return :continue, [:right, {:right => 50}]
    end
  end
end

#初期化
Window.resize(1280, 720)

tsukasa = Tsukasa.new({ :width => 1280,
                        :height => 720,
                        :id => :default_layout_container
                        }) do
  #Testコントロールの生成
  create :Test , file_path: "./sozai/button_normal.png", id: :BG1 do
    right 50
  end
end

#ゲームループ
Window.loop do
  #pp "frame"
  #Ragエンジン処理
  tsukasa.update
  #Ragエンジン描画
#  rag.render(0, 0, Window, 1280, 720)
  tsukasa.render(0, 0, Window)
end