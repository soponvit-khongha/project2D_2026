# Point & Click Starter Kit

This starter kit provides all the essential mechanics needed to build a complete 2D Point-and-Click adventure game in Godot 4.7. It is designed as a hands-on learning resource for students taking the **Computer Game Development** course at the **College of Computing, Khon Kaen University**.

## Preview

<img src="docs/qrcode.png" style="width:300px;" />

- [Game Preview](https://computingkku.github.io/2D-Platformer-Starter-Kit/)


## Features

- **Game Menu** — A simple main menu scene (`Menu.tscn`) with Start and Exit options, so players can launch into the game or quit cleanly.
- **Mobile & Web Design** — Touch-friendly interface allowing player movement, interactions, and menu navigation using standard clicks or taps across PC, mobile, and web browsers.
- **Point & Click Controller** — Pathfinding-based player movement (using NavigationAgent2D) that allows the character to walk smoothly to clicked locations on the screen.
- **Interactive Object System** — Hotspots and interactable objects in the environment that trigger actions (examine, interact) on click/tap.
- **Dialogue & Choice System** — Multi-choice dialogue interface for talking to NPCs, with support for branching paths, story variables, and puzzle triggers.
- **Animated Character** — Walking, idle, and interaction animations with path direction awareness; sprite flips and changes direction automatically.
- **Visual Feedback & Effects** — Dynamic cursor icon changes (inspect, talk, walk), particle cues on interaction, and visual feedback for puzzle solutions.
- **Score & Quest Tracking** — Track completed puzzles, collected clues, and progress using a real-time game state manager.
- **Demo Scenes** — Hand-crafted rooms/scenes introducing common point-and-click design patterns and room transitions.
- **Level & Scene Management** — Clean transitions between rooms and locations using an autoload transition manager.
- **Beginner-Friendly Code** — Every script is documented and structured to be easy to read, modify, and extend.

## Getting Started

1. Open the project in [Godot 4.7](https://godotengine.org/) or later.
2. Press **F5** or click **Play** to run the main menu.
3. Use **Left Click** (or **Tap**) on the screen to walk, examine objects, interact, or talk to NPCs.
4. Solve environment puzzles, gather clues, and interact with objects to progress through the story.

## Controls

| Input | Action |
|-------|--------|
| Left Click / Tap | Move to position / Interact with object or NPC |
| Hover | Dynamic cursor changes based on interaction type |
| Touch Controls | Fully supported for mobile and web tap interactions |

## Inspector Tips

- **Player**: Adjust `move_speed`, set `navigation_agent` properties, and configure interaction distance threshold directly in the inspector.
- **Hotspot / Interactable**: Configure `interaction_type` (Examine, Talk, Interact) and dialogue trigger files.
  
## Project Structure
