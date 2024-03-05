property sp, goal, moves
global glob

on beginSprite me
  glob[#movenum] = me
  sp = sprite(me.spriteNum)
  updateMovesNum(me)
end

on updateMovesNum me
  building = glob[#current][#building]
  level = glob[#current][#level]
  goal = glob[#building][building][#LEVELS][level][#goal]
  moves = integer(member("play move counter field").text)
  member("goal_amount_indicator").text = string(goal) & " or fewer"
end

on exitFrame me
  moves = integer(member("play move counter field").text)
  if moves <= goal then
    sp.blend = 100
  else
    sp.blend = 0
  end if
end
