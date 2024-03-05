property which
global glob

on mouseUp me
  if sprite(me.spriteNum).blend = 0 then
    exit
  end if
  case which of
    #com_nextlevel:
      level = glob[#current][#level]
      building = glob[#current][#building]
      if (level = 15) and not (building = 4) then
        lock = glob[#building][building + 1][#state]
        if lock = #open then
          glob[#current][#building] = glob[#current][#building] + 1
        end if
      end if
      glob.BIG_MSG_OBJ.updateState(#move2, [#object: glob.PLAYER.game_manager, #parameter: #com_nextlevel])
    #com_selectlevel:
      glob.BIG_MSG_OBJ.updateState(#move2, [#object: glob.PLAYER.game_manager, #parameter: #select_level])
    #fail_tryagain:
      glob.fail_msg_obj.updateState(#move2, [#object: glob.PLAYER.game_manager, #parameter: #restart_level])
    #fail_gethint:
      glob[#hint_obj].updateState(#move2)
    #fail_selectlevel:
      glob.fail_msg_obj.updateState(#move2, [#object: glob.PLAYER.game_manager, #parameter: #select_level])
  end case
end

on mouseDown me
  if sprite(me.spriteNum).blend = 0 then
    exit
  end if
  SndSFX("h_button1")
end

on getPropertyDescriptionList me
  return [#which: [#format: #propList, #comment: "which button", #range: [#com_nextlevel, #fail_tryagain, #fail_gethint, #fail_selectlevel], #default: #none]]
end
