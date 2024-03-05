property myText, howmany
global glob

on beginSprite me
  howmany = the number of castMembers of castLib "levels"
  myText = sprite(me.spriteNum).member
  temp = EMPTY
  repeat with n = 1 to howmany
    temp = temp & member(n, "levels").name & RETURN
  end repeat
  myText.text = temp
end

on mouseUp me
  whichLevel = the mouseLine
  if whichLevel > howmany then
    return 
  else
    levelList = []
    repeat with n = whichLevel to howmany
      levelList.add(member(n, "levels").text)
    end repeat
    glob.PLAYER.game_manager.setGame(levelList)
    glob.PLAYER.game_manager.startGame()
  end if
end
