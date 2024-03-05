global glob

on beginSprite me
  if glob[#rankdata][#keys] < glob[#hof] then
  else
    barwidth = 125
    rank = glob[#rankdata][#rank]
    total = glob[#rankdata][#players]
    if rank = 0 then
      mybar = barwidth
    else
      ratio = total / rank
      mybar = barwidth - (barwidth / ratio)
    end if
    sprite(me.spriteNum).width = mybar
    if (the frameLabel = "levels") or (the frameLabel = "credits") then
      sprite(me.spriteNum).loc = point(497, 296)
    else
      if not voidp(glob[#master_obj]) then
        if not voidp(glob[#master_obj].Prop[#state]) then
          if glob[#master_obj].Prop[#state] = #hide then
            sprite(me.spriteNum).loc = point(1000, 1000)
          else
            sprite(me.spriteNum).loc = point(76, 335)
          end if
        else
          sprite(me.spriteNum).loc = point(1000, 1000)
        end if
      else
        sprite(me.spriteNum).loc = point(1000, 1000)
      end if
    end if
    member("rank_box1").text = string(glob[#rankdata][#rank])
    member("rank_box2").text = "out of " & string(glob[#rankdata][#players])
  end if
end
