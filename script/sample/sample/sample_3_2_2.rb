_CREATE_ :Layout, id: :save_test

_HALT_

_SEND_ :save_test do
  _QUICK_LOAD_ "./datastore/quick_data.dat"
end

_HALT_

_END_PAUSE_