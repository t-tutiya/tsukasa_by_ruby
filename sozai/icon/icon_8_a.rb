      _WHILE_ [:true] do
        set 7, visible: false
        set 0, visible: true
      	_WAIT_ [:count], count: 5
        set 0, visible: false
        set 1, visible: true
      	_WAIT_ [:count], count: 5
        set 1, visible: false
        set 2, visible: true
      	_WAIT_ [:count], count: 5
        set 2, visible: false
        set 3, visible: true
      	_WAIT_ [:count], count: 5
        set 3, visible: false
        set 4, visible: true
      	_WAIT_ [:count], count: 5
        set 4, visible: false
        set 5, visible: true
      	_WAIT_ [:count], count: 5
        set 5, visible: false
        set 6, visible: true
      	_WAIT_ [:count], count: 5
        set 6, visible: false
        set 7, visible: true
      	_WAIT_ [:count], count: 30
      end