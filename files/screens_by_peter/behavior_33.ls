global glob

on mouseWithin me
  locked = glob[#level_scrn_obj].roTab(me.spriteNum, 100)
end

on mouseLeave me
  glob[#level_scrn_obj].roTab(me.spriteNum, 0)
end

on mouseUp me
  glob[#level_scrn_obj].tabClicked(me.spriteNum)
end
