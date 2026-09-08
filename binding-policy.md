# Binding Policy — Hard Rule

ConsolePortOcto must never modify persistent WoW keybindings.

The addon may:
- read keybindings
- display keybinding state
- react to normal game state
- expose addon commands

The addon may not:
- write bindings
- save bindings
- replace the player's existing keyboard layout
- silently remap keyboard controls

The same WoW installation should remain usable from a normal PC keyboard after Steam Deck play.
