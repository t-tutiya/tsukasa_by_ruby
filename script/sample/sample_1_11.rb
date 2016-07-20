#ルール画像を設定するユーザー定義コマンド
_DEFINE_ :set_rule do |argument, options|
  _CREATE_ :RuleShaderControl, id: options[:id], vague: options[:vague] || 40,
            file_path: options[:file_path]
  _SET_ shader: options[:id]
end

#前回と同じ
_CREATE_ :RenderTargetControl, id: :test0, width: 800, height: 600 do
  _CREATE_ :ImageControl, file_path: "./resource/bg_test.jpg"
  _CREATE_ :ImageControl, file_path: "./resource/char/B-1.png", x: 250
end

_CREATE_ :ImageControl, id: :test1, file_path: "./resource/bg_sample.png" do
  set_rule id: :rule0, vague: 40,
           file_path: "./resource/rule/horizontal_rule.png"
end

#前回と同じ
_WAIT_  key_push: K_SPACE, system: [:mouse_push]

#ルールトランジションを実行するユーザー定義コマンド
_DEFINE_ :go_rule do |argument, options|
  _SEND_ :test1 do
    _SEND_ options[:rule_id] do
      _MOVE_ options[:time], counter:[0,255]
      _DELETE_
    end
    _WAIT_ child_not_exist: :rule0
    _DELETE_
  end
end

go_rule rule_id: :rule0, time: 240

_END_PAUSE_
_DELETE_ :test0