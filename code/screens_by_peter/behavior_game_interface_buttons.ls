property my, myName
global glob

on beginSprite me
  my = sprite(me.spriteNum)
  myName = my.member.name
end

on mouseUp me
  case myName of
    "restart_level":
      gbutton(#main_play)
    "mainmenu":
      glob.PLAYER.game_manager.exitGame()
      go("levels")
    "fail_tryAgain":
      gbutton(#main_play)
    "gotohelp":
      glob.PLAYER.game_manager.exitGame()
      go("help")
  end case
end

on mouseDown me
  SndSFX("h_button1")
  sendAllSprites(#getOut)
end

on mouseEnter me
  my.member = member(myName & "_x")
end

on mouseLeave me
  my.member = member(myName)
end
