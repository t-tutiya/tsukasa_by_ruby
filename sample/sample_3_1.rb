_DEFINE_ :a do
	b do
		_EVAL_ "pp 'a'"
		_LOOP_ count:3 do
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

		_LOOP_  count:3 do
  		_EVAL_ "pp 'top loop'"
		end
