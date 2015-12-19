_DEFINE_ :a do
	b do
		_EVAL_ "pp 'a'"
		_LOOP_ count:3,continuation: true do
  		_EVAL_ "pp 'loop'"
  		_YIELD_
		end
	end
end

_DEFINE_ :b do
	_EVAL_ "pp 'b'"
	_YIELD_
end

a do
	_EVAL_ "pp 'top'"
end
=begin
		_LOOP_  count:3,continuation: true  do
  		_EVAL_ "pp 'top loop'"
		end

		_LOOP_  count:3,continuation: true  do
  		_EVAL_ "pp 'top loopB'"
		end
=end

_DEFINE_ :a2 do
	b2 do
	  _INCLUDE_ "./sample/sample_3_1b.rb"
	end
end

_DEFINE_ :b2 do
	_EVAL_ "pp 'b2'"
	_YIELD_
end

a2 do
	_EVAL_ "pp '2 top'"
end

