#! ruby -E utf-8

test_if do
  test_exp do
    true
  end
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

test_if do
  test_exp do
    false
  end
  test_then do
    define :func2 do
      pp "func2 then"
    end
  end
  test_else do
    define :func2 do
      pp "func2 else"
    end
  end
end

func2