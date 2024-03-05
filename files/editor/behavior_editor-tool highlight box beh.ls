property s
global glob

on beginSprite me
  s = sprite(me.spriteNum)
  s.loc = point(-100, -100)
  glob.EDITOR[#tool_highlight_box] = s
end

on highlight me, spr
  s.rect = spr.rect + rect(-4, -4, 4, 4)
end
