global glob

on initSound
  glob[#whichMusic] = "none"
  glob[#musicChannel1] = 1
  glob[#musicChannel2] = 2
  glob[#sfxChannels] = [3, 4, 5, 6, 7, 8]
  glob[#musicIsPlaying] = 0
  glob[#soundSection] = 0
end

on SndCheckPlaylist
  if (glob[#musicIsPlaying] = 1) and (sound(glob[#musicChannel1]).getPlayList().count < 5) then
    SndLevelQueue()
  end if
end

on SndLevelQueue
  playlist1 = glob[#whichMusic]
  myList1 = [[:]]
  repeat with i = 1 to SNDGetLineCount(playlist1)
    if word 1 of line 1 of the text of member playlist1 = "random" then
      myMember1 = member(line random(SNDGetLineCount(playlist1)) + 1 of the text of member playlist1)
    else
      if word 1 of line 1 of the text of member playlist1 = "playlist" then
        j = ((i - 1) mod SNDGetLineCount(playlist1)) + 2
        myMember1 = member(line j of the text of member playlist1)
      end if
    end if
    lowestDuration = myMember1.duration
    repeat with j = 1 to word 2 of line 1 of the text of member playlist1
      sound(glob[#musicChannel1]).queue([#member: myMember1, #startTime: 0, #endTime: lowestDuration, #preLoadTime: 1500])
    end repeat
  end repeat
end

on SndMusicStart whichMusic
  put whichMusic
  glob[#whichMusic] = whichMusic
  sound(glob[#musicChannel1]).stop()
  playlist1 = whichMusic
  sound(glob[#musicChannel1]).setPlayList([:])
  myList1 = [[:]]
  repeat with i = 1 to SNDGetLineCount(playlist1)
    if word 1 of line 1 of the text of member playlist1 = "random" then
      myMember1 = member(line random(SNDGetLineCount(playlist1)) + 1 of the text of member playlist1)
    else
      if word 1 of line 1 of the text of member playlist1 = "playlist" then
        j = ((i - 1) mod SNDGetLineCount(playlist1)) + 2
        myMember1 = member(line j of the text of member playlist1)
      end if
    end if
    lowestDuration = myMember1.duration
    repeat with j = 1 to word 2 of line 1 of the text of member playlist1
      myList1.add([#member: myMember1, #startTime: 0, #endTime: lowestDuration, #preLoadTime: 1500])
    end repeat
  end repeat
  sound(glob[#musicChannel1]).setPlayList(myList1)
  sound(glob[#musicChannel1]).pan = 0
  sound(glob[#musicChannel1]).play()
  glob[#musicIsPlaying] = 1
end

on SndMusicEnd
  if glob[#musicIsPlaying] = 1 then
    glob[#musicIsPlaying] = 0
    sound(glob[#musicChannel1]).setPlayList([:])
    sound(glob[#musicChannel2]).setPlayList([:])
    memberCheck = member(glob[#whichMusic] & ".end").number
    if memberCheck > 0 then
      playlist1 = glob[#whichMusic] & ".end"
      myList1 = [[:]]
      repeat with i = 1 to SNDGetLineCount(playlist1)
        if word 1 of line 1 of the text of member playlist1 = "random" then
          myMember1 = member(line random(SNDGetLineCount(playlist1)) + 1 of the text of member playlist1)
        else
          if word 1 of line 1 of the text of member playlist1 = "playlist" then
            j = ((i - 1) mod SNDGetLineCount(playlist1)) + 2
            myMember1 = member(line j of the text of member playlist1)
          end if
        end if
        lowestDuration = myMember1.duration
        myList1.add([#member: myMember1, #startTime: 0, #endTime: lowestDuration, #preLoadTime: 1500])
      end repeat
      sound(glob[#musicChannel1]).setPlayList(myList1)
    end if
  end if
end

on SNDGetLineCount myMember
  myLineCount = 0
  repeat with i = 1 to member(myMember).line.count
    if line i of the text of member myMember <> EMPTY then
      myLineCount = myLineCount + 1
    end if
  end repeat
  myLineCount = myLineCount - 1
  return myLineCount
end

on SndStop
  glob[#soundSection] = "0"
  sound(glob[#musicChannel1]).setPlayList([:])
  sound(glob[#musicChannel2]).setPlayList([:])
  sound(glob[#musicChannel1]).stop()
  sound(glob[#musicChannel2]).stop()
  numberOfChannels = glob[#sfxChannels].count
  repeat with i = 1 to numberOfChannels
    whichChannel = getAt(glob[#sfxChannels], i)
    sound(whichChannel).setPlayList([:])
    sound(whichChannel).stop()
  end repeat
  glob[#musicIsPlaying] = 0
end

on SndSFX whichSound, sfxpan, sfxlevel, sfxpitch
  numberOfChannels = glob[#sfxChannels].count
  myList1 = []
  soundHasBeenPlayed = 0
  if sfxpan = VOID then
    sfxpan = 0
  end if
  if sfxlevel = VOID then
    sfxlevel = 255
  end if
  if sfxpitch = VOID then
    sfxpitch = 0
  end if
  repeat with i = 1 to numberOfChannels
    if soundBusy(getAt(glob[#sfxChannels], i)) = 0 then
      sound(getAt(glob[#sfxChannels], i)).volume = sfxlevel
      sound(getAt(glob[#sfxChannels], i)).pan = sfxpan
      puppetSound(getAt(glob[#sfxChannels], i), whichSound)
      soundHasBeenPlayed = 1
      exit repeat
    end if
  end repeat
  if soundHasBeenPlayed = 0 then
    puppetSound(getAt(glob[#sfxChannels], 1), whichSound)
  end if
end
