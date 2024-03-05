global glob

on mouseUp me
  glob.PLAYER.game_manager.exitGame()
  glob.download_manager.mainmenu()
end

on mouseDown me
  SndSFX("h_button1")
end
