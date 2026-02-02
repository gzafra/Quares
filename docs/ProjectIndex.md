# Quares Project Index

## Overview

**Project**: Quares - A color-matching puzzle iOS game
**Frameworks**: SwiftUI + SpriteKit
**Architecture**: MVVM with Delegate Pattern

---

## Files Reference

### App Entry Point

| File | Description |
|------|-------------|
| `App/QuaresApp.swift` | SwiftUI app entry point. Sets up WindowGroup with MainMenuView. |

### Views (SwiftUI Layer)

| File | Description |
|------|-------------|
| `Views/MainMenuView.swift` | Main menu with title, Play and Options buttons. Uses NavigationStack. |
| `Views/GameView.swift` | SpriteKit scene container. Uses GeometryReader for sizing. |
| `Views/OptionsView.swift` | Placeholder options screen (future implementation). |

### ViewModels

| File | Description |
|------|-------------|
| `ViewModels/GameViewModel.swift` | Owns Brain and GameScene. Handles game lifecycle and exit/restart callbacks. |
| `ViewModels/MainMenuViewModel.swift` | Manages NavigationPath for menu navigation. |

### Models

| File | Description |
|------|-------------|
| `Models/GameConfiguration.swift` | Centralized game settings: grid size, colors, health drain, scoring. |

### Game Logic

| File | Description |
|------|-------------|
| `Game/Brain.swift` | Core game engine. Grid state, selection, matching, scoring, health, difficulty scaling. |
| `Game/GameScene.swift` | SpriteKit scene. Rendering, touch handling, animations. |
| `Game/GameScene+BrainDelegate.swift` | Extension implementing BrainDelegate. Bridges Brain → GameScene. |

### SpriteKit Components

| File | Description |
|------|-------------|
| `Game/Components/SquareNode.swift` | Individual grid square visual. Highlight and animation support. |
| `Game/Components/HealthBar.swift` | Health bar UI with color-coded fill (green/yellow/red). |
| `Game/Components/ScoreBoard.swift` | Score display label. |
| `Game/Components/GameOverScreen.swift` | Game over modal with Restart/Exit buttons. |

### Tests

| File | Description |
|------|-------------|
| `QuaresTests/BrainTests.swift` | Comprehensive unit tests for Brain logic. 35+ test cases. |

---

## Protocols

### BrainDelegate
**Location**: `Game/Brain.swift`
**Purpose**: Notifies observers of game state changes from Brain.

| Method | Description |
|--------|-------------|
| `brainDidUpdateGrid(_:)` | Grid state changed |
| `brainDidUpdateHealth(_:health:)` | Health value changed |
| `brainDidUpdateScore(_:score:)` | Score changed |
| `brainDidGameOver(_:)` | Game ended |
| `brainDidSelectSquares(_:squares:)` | Selection preview |
| `brainDidClearSelection(_:)` | Selection cleared |
| `brainDidClearSquares(_:from:to:)` | Successful match animation |
| `brainDidFailSelection(_:from:to:)` | Failed match animation |

### GameSceneDelegate
**Location**: `Game/GameScene.swift`
**Purpose**: GameScene → ViewModel communication for navigation.

| Method | Description |
|--------|-------------|
| `gameSceneDidRequestExit(_:)` | User tapped exit button |
| `gameSceneDidRequestRestart(_:)` | User tapped restart button |

### GameOverScreenDelegate
**Location**: `Game/Components/GameOverScreen.swift`
**Purpose**: Button callbacks from game over modal.

| Method | Description |
|--------|-------------|
| `gameOverScreenDidTapRestart(_:)` | Restart button tapped |
| `gameOverScreenDidTapExit(_:)` | Exit button tapped |

---

## Classes

### Brain
**Location**: `Game/Brain.swift` (271 lines)
**Responsibility**: Core game engine - all game logic without UI dependencies.

**Key Properties**:
- `grid: [[Square]]` - 2D array of game squares
- `score: Int` - Current player score
- `health: Double` - Health value (0.0 - 1.0)
- `isGameOver: Bool` - Game state flag
- `selectedPosition: GridPosition?` - First corner of selection
- `configuration: GameConfiguration` - Game settings

**Key Methods**:
- `startGame()` / `resetGame()` / `pauseGame()` / `resumeGame()`
- `selectSquare(at:)` - Handle square tap
- `attemptMatch(from:to:)` - Check if corners match and clear
- `drainHealth(deltaTime:)` - Continuous health drain (difficulty scales with score)
- `regenerateHealth()` - Add health on successful match

### GameScene
**Location**: `Game/GameScene.swift` (283 lines)
**Responsibility**: SpriteKit rendering and touch input handling.

**Key Properties**:
- `brain: Brain` - Reference to game engine
- `squareNodes: [[SquareNode]]` - Visual grid
- `healthBar: HealthBar?` - Health UI component
- `scoreBoard: ScoreBoard?` - Score UI component

**Key Methods**:
- `setupGrid()` / `setupHealthBar()` / `setupScoreBoard()`
- `touchesBegan/Moved/Ended/Cancelled` - Drag-to-select input
- `animateSuccessfulSelection(from:to:)` - Match success animation
- `animateFailedSelection(from:to:)` - Match failure animation

### GameViewModel
**Location**: `ViewModels/GameViewModel.swift` (47 lines)
**Responsibility**: Game state management and scene lifecycle.

**Published Properties**:
- `shouldDismiss: Bool` - Triggers navigation back to menu

### MainMenuViewModel
**Location**: `ViewModels/MainMenuViewModel.swift` (23 lines)
**Responsibility**: Navigation state for main menu.

**Published Properties**:
- `navigationPath: NavigationPath` - SwiftUI navigation stack

### SquareNode
**Location**: `Game/Components/SquareNode.swift` (69 lines)
**Responsibility**: Individual grid square visual with animations.

### HealthBar
**Location**: `Game/Components/HealthBar.swift` (64 lines)
**Responsibility**: Health bar rendering with color-coded fill.

### ScoreBoard
**Location**: `Game/Components/ScoreBoard.swift` (27 lines)
**Responsibility**: Score display label.

### GameOverScreen
**Location**: `Game/Components/GameOverScreen.swift` (113 lines)
**Responsibility**: Modal overlay with restart/exit buttons.

---

## Structs

### GridPosition
**Location**: `Game/Brain.swift`
**Purpose**: Value type for grid coordinates.

**Properties**: `x: Int`, `y: Int`
**Static Methods**: `area(from:to:)`, `corners(from:to:)`

### Square
**Location**: `Game/Brain.swift`
**Purpose**: Individual square data.

**Properties**: `colorIndex: Int`, `isEmpty: Bool`

### GameConfiguration
**Location**: `Models/GameConfiguration.swift`
**Purpose**: Centralized game settings.

**Properties**:
- `gridSize: Int` (default: 10)
- `numberOfColors: Int` (default: 5)
- `initialHealthDrainDuration: TimeInterval` (default: 30.0)
- `minimumHealthDrainDuration: TimeInterval` (default: 2.0)
- `healthRegenerationPercentage: Double` (default: 0.15)
- `baseMultiplier: Double` (default: 1.0)
- `difficultyIncreasePerScore: Int` (default: 100)
- `drainSpeedIncreasePercentage: Double` (default: 0.1)

---

## Game Mechanics

1. **Grid**: 10x10 colored squares (configurable)
2. **Selection**: Drag from corner to corner to define rectangle
3. **Matching**: All 4 corners must be same color to clear area
4. **Scoring**: Cleared squares × multiplier
5. **Health**: Continuously drains, regenerates on match
6. **Difficulty**: Drain rate increases as score rises
7. **Game Over**: Health reaches zero
