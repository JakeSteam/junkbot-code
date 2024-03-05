property READY, page
global glob

on beginSprite me
  glob.database_manager.loadHallOfFame()
  READY = 0
  member("HOF_rank").text = EMPTY
  member("HOF_names").text = RETURN & "LOADING" & RETURN
  member("HOF_moves").text = EMPTY
  page = 1
end

on prepareFrame me
  if not READY then
    READY = me.displayhof()
  end if
end

on pageP me, a
  if not glob.database_manager.hofReady() then
    return 0
  end if
  case a of
    #prev:
      return page > 1
    #next:
      return page < 8
  end case
end

on page me, a
  if not me.pageP(a) then
    return 
  end if
  case a of
    #prev:
      page = page - 1
    #next:
      page = page + 1
  end case
  me.displayhof()
end

on displayhof me
  if glob.database_manager.hofReady() then
    hof = glob.database_manager.getHallOfFame()
    ranks = EMPTY
    names = EMPTY
    moves = EMPTY
    Start = 1 + ((page - 1) * 13)
    finish = Start + 12
    if finish > 100 then
      finish = 100
    end if
    repeat with i = Start to finish
      ranks = ranks & i & "." & RETURN
      namekey = symbol("u" & i)
      movekey = symbol("t" & i)
      names = names & hof[namekey] & RETURN
      moves = moves & hof[movekey] & RETURN
    end repeat
    member("HOF_rank").text = ranks
    member("HOF_moves").text = moves
    member("HOF_names").text = names
    return 1
  else
    return 0
  end if
end
