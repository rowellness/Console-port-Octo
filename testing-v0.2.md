# v0.2 In-game Test Checklist

1. Put `ConsolePortOcto` in `Interface/AddOns`.
2. Log in.
3. Confirm chat shows `ConsolePortOcto: Loaded v0.2.0-alpha`.
4. Confirm HUD appears near bottom-center.
5. Press/hold Shift on keyboard:
   - HUD label should change BASE -> SHIFT.
6. Hold Ctrl:
   - HUD label should change -> CTRL.
7. Hold Alt:
   - HUD label should change -> ALT.
8. Verify icons correspond to actions currently bound to 1-7 and modified 1-7.
9. Put an ability with cooldown on one of those action slots and use it.
   - cooldown countdown should appear.
10. Move out of range:
   - applicable action should tint red.
11. Open Character panel:
   - HUD state should show `UI NAV • CHARACTER`.
12. Open Spellbook:
   - should show `UI NAV • SPELLBOOK`.
13. Open Talents:
   - should show `UI NAV • TALENTS`.
14. Open bags:
   - should show `UI NAV • BAGS`.
15. `/cpo unlock`, drag HUD, `/cpo lock`.
16. Reload UI and confirm position persists.
17. `/cpo status` and report the output if something behaves incorrectly.

If the addon throws a Lua error, capture the exact error text and line number.
