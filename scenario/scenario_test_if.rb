#! ruby -E utf-8

IF ->{true} do
  THEN do
    define :func do
      pp "func then"
    end
  end
  ELSE do
    define :func do
      pp "func else"
    end
  end
end

func

IF ->{false} do
  THEN do
    define :func2 do
      pp "func2 then"
    end
  end
  ELSE do
    IF ->{true} do
      THEN do
        define :func2 do
          pp "func2 else then"
        end
      end
      ELSE do
        define :func2 do
          pp "func2 else else"
        end
      end
    end
  end
end

func2


IF ->{false} do
  THEN do
    define :func3 do
      pp "func3 then"
    end
  end
  ELSIF ->{true} do
    define :func3 do
      pp "func3 elsif"
    end
  end
  ELSE do
    define :func3 do
      pp "func else"
    end
  end
end

func3
