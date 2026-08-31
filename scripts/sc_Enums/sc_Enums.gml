enum GameState
{
    BOOT,
    MENU,
    PLAYING,
    PAUSED,
    GAME_OVER
}

enum LevelState
{
    NONE,
    INITIALIZING,
    PLAYING,
    COMPLETE,
    FAILED,
    EXITING
}

enum PlayerState
{
    INITIALIZING,
    ACTIVE,
    STUNNED,
    DISABLED,
    DESTROYED
}