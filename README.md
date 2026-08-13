## To do:

- [ ] Figure out why the Pukka doesn't work? (Can't remember why I disabled it and said it doesn't work)
- [ ] Game ends if no execution on final 3 and no protection role which might prevent the Demon killing
- [ ] Grim reveal before game ends
- [ ] Generic tokens (T, O, M, D) for roles

### Changelog

## Beta 3 - 2026.08.13

- Roles now show their ability text if you hover over them on the "Script" page of the Info Book

## Beta 2 - 2026.08.12

- Ghost votes now work (players were not being given a ghost vote on death, whoops)
- "Nominations are now open" message/timer now disappears when a nomination happens
- Fixed "End Defence Early" button not working
- Seat buttons are disabled during voting to avoid confusion; **but**, players can now click on their own seat button to toggle their vote
- Mouse input is automatically enabled for nominations/other button UIs
- Executed players now look upwards (to see their impending anvil-flavoured doom)
- Added sounds (intro, books, morning/night/vote countdown)

## Beta 1 - 2026.08.12

- 'Once per game' roles now, yaknow, only act once per game
- Discussion time is now no longer hard-coded to 3 seconds (lol oops) and has a convar
- Pressing Esc to close the books will no longer also open the pause menu
- Admin books will now not be given if testing mode isn't enabled
- Added testing mode convar(`randomat_joelbotc_enable_testing_mode`) which triggers the event but doesn't start the first night
- Book close buttons are now prettier and also won't get cut off the bottom of the screen