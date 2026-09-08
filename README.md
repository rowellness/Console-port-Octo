# ConsolePortOcto

Steam Deck-oriented controller HUD and navigation framework for Turtle WoW / OctoWoW (1.12-style client).

## Version 0.2.0-alpha — first visible/playable build

This build adds a real in-game controller HUD. It reads the player's existing WoW bindings and mirrors the actions attached to the project's controller keys.

### Working now

- Visible Steam Deck-style HUD
- Base / LT=Shift / RT=Ctrl / LT+RT=Alt layer display
- Live modifier detection with `IsShiftKeyDown`, `IsControlKeyDown`, `IsAltKeyDown`
- X/Y/B/D-pad controller layout
- A shows JUMP only on the base layer
- Modified A is intentionally free
- Reads existing bindings with `GetBindingAction`
- Resolves normal action-button and multi-action-bar bindings to real WoW action slots
- Displays action icons
- Displays stack/charge count
- Displays cooldown countdown
- Dims unusable actions
- Red-tints out-of-range actions
- Detects Character / Spellbook / Talent / Bag frames and shows UI state
- Mouse-mode state and indicator
- Draggable HUD with `/cpo unlock`
- Saved HUD position/scale only
- Optional SuperWoW presence detection
- No persistent WoW keybinding writes

### Not implemented yet

- D-pad focus navigation inside Blizzard panels
- A confirm / Y equip / B cancel in UI navigation
- automatic hardware detection of left-stick-click mouse toggle
- controller cursor implementation
- direct Steam Input communication
- Nampower-enhanced data adapter

Those require a deliberate input bridge. They will not be implemented by silently remapping the user's keys.

## HARD RULE

**ConsolePortOcto must never modify persistent WoW keybindings.**

The addon source must not execute:
- `SetBinding`
- `SaveBindings`

Steam Input owns physical-controller mapping. ConsolePortOcto reads and presents the bindings WoW already has.

## Install

Copy:

`ConsolePortOcto`

to:

`World of Warcraft/Interface/AddOns/`

Restart WoW and enable the addon.

## Commands

- `/cpo status`
- `/cpo show`
- `/cpo hide`
- `/cpo unlock`
- `/cpo lock`
- `/cpo reset`
- `/cpo scale 0.8`
- `/cpo scale 1.2`
- `/cpo mouse`
- `/cpo debug`
- `/cpo help`

## Important Steam Input assumption

The HUD contract is:

- X -> 1
- Y -> 2
- B -> 3
- D-pad Up -> 4
- D-pad Right -> 5
- D-pad Down -> 6
- D-pad Left -> 7
- A -> Jump only on base layout
- LT -> Shift
- RT -> Ctrl
- LT+RT -> Alt

The HUD reads whatever WoW currently has bound to `1-7`, `SHIFT-1-7`, `CTRL-1-7`, and `ALT-1-7`.

It never changes those bindings.
