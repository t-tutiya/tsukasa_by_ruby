#! ruby -E utf-8

test_if ->{true} do
  test_then do
    define :func do
      pp "func then"
    end
  end
  test_else do
    define :func do
      pp "func else"
    end
  end
end

func

test_if ->{false} do
  test_then do
    define :func2 do
      pp "func2 then"
    end
  end
  test_else do
    test_if ->{true} do
      test_then do
        define :func2 do
          pp "func2 else then"
        end
      end
      test_else do
        define :func2 do
          pp "func2 else else"
        end
      end
    end
  end
end

func2


test_if ->{false} do
  test_then do
    define :func3 do
      pp "func3 then"
    end
  end
  test_elsif ->{true} do
    define :func3 do
      pp "func3 elsif"
    end
  end
  test_else do
    define :func3 do
      pp "func else"
    end
  end
end

func3
