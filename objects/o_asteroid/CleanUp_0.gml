/// @description Removes this asteroid from the active level count.
if (level_counted
&& variable_global_exists("level")
&& is_struct(global.level))
{
    global.level.asteroids_alive = max(0, global.level.asteroids_alive - 1);
    level_counted = false;
}