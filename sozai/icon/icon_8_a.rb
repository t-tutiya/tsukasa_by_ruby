      _WHILE_ stop: false do
        _SEND_(7){_SET_  visible: false}
        _SEND_(0){_SET_  visible: true}
      	_WAIT_ count: 5
        _SEND_(0){_SET_  visible: false}
        _SEND_(1){_SET_  visible: true}
      	_WAIT_ count: 5
        _SEND_(1){_SET_  visible: false}
        _SEND_(2){_SET_  visible: true}
      	_WAIT_ count: 5
        _SEND_(2){_SET_  visible: false}
        _SEND_(3){_SET_  visible: true}
      	_WAIT_ count: 5
        _SEND_(3){_SET_  visible: false}
        _SEND_(4){_SET_  visible: true}
      	_WAIT_ count: 5
        _SEND_(4){_SET_  visible: false}
        _SEND_(5){_SET_  visible: true}
      	_WAIT_ count: 5
        _SEND_(5){_SET_  visible: false}
        _SEND_(6){_SET_  visible: true}
      	_WAIT_ count: 5
        _SEND_(6){_SET_  visible: false}
        _SEND_(7){_SET_  visible: true}
      	_WAIT_ count: 30
      end