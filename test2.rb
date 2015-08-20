a = [:test, [:test2, :test3]]

str = Marshal.dump(a)
p Marshal.load(str)
