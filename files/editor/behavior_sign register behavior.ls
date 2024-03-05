property my, who
global glob

on beginSprite me
  my = sprite(me.spriteNum)
  my.blend = 0
  glob.PLAYER[#signsprite] = my
end

on showSign me, memName, pram
  who = pram
  my.member = member(memName)
  my.blend = 100
  my.locZ = 10000000
end

on hideSign me
  my.blend = 0
end

on mouseUp me
  case who of
    #gameOverButton:
      gbutton(#main_play)
    #goNextLevelButton:
      glob.PLAYER.game_manager.goNextLevelButton()
  end case
  hideSign(me)
end
