global glob

on goldTotal
  gotgold = 0
  repeat with building = 1 to 4
    repeat with level = 1 to 15
      moves = glob[#building][building][#LEVELS][level][#moves]
      goal = glob[#building][building][#LEVELS][level][#goal]
      if (moves > 0) and (goal >= moves) then
        gotgold = gotgold + 1
      end if
    end repeat
  end repeat
  return gotgold
end
