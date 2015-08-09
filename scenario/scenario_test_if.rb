#! ruby -E utf-8

IF ->{true} do
  THEN do
    _DEFINE_ :func do
      pp "func then"
    end
  end
  ELSE do
    _DEFINE_ :func do
      pp "func else"
    end
  end
end

func

IF ->{false} do
  THEN do
    _DEFINE_ :func2 do
      pp "func2 then"
    end
  end
  ELSE do
    IF ->{true} do
      THEN do
        _DEFINE_ :func2 do
          pp "func2 else then"
        end
      end
      ELSE do
        _DEFINE_ :func2 do
          pp "func2 else else"
        end
      end
    end
  end
end

func2


IF ->{false} do
  THEN do
    _DEFINE_ :func3 do
      pp "func3 then"
    end
  end
  ELSIF ->{true} do
    _DEFINE_ :func3 do
      pp "func3 elsif"
    end
  end
  ELSE do
    _DEFINE_ :func3 do
      pp "func else"
    end
  end
end

func3
