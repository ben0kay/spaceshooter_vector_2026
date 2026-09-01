enum GameState {
    BOOT,
    MENU,
    PLAYING
}

enum LevelState {
    NONE,
    INITIALIZING,
    SHIP_SELECT,
    PLAYING,
    PAUSED,
    COMPLETE,
    FAILED
}

enum PlayerState {
    NONE,
    SPAWNING,
    ACTIVE,
    DISABLED,
    DESTROYED
}

enum MainMenuAction {
    DEPLOY,
    HANGAR,
    OPTIONS,
    CHANGE_PROFILE,
    EXIT
}