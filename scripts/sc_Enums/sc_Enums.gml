//==================================================
// GAME / FLOW STATES
//==================================================
enum GameState { BOOT, MENU, PLAYING, PAUSED, GAME_OVER }
enum LevelState { NONE, INITIALIZING, SHIP_SELECT, PLAYING, COMPLETE, FAILED, EXITING }
enum PlayerState { INITIALIZING, ACTIVE, DASHING, STUNNED, INVENTORY, DISABLED, DESTROYED }
enum BossEncounterState { WAITING, APPROACH, WAVE, BOSS, VICTORY }
//==================================================
// UI / MENU
//==================================================
enum InventoryTab { CARGO, EQUIPMENT, SYSTEMS, UPGRADES, NAVIGATION, LOG }
enum MainMenuAction { DEPLOY, HANGAR, OPTIONS, CHANGE_PROFILE, EXIT }
//==================================================
// FACTIONS / ENEMY STATE
//==================================================
enum Faction { PLAYER, SIMULANT, REBEL, CORPORATION, ALIEN, AUTOMATED }
enum EnemyState { IDLE, INVESTIGATING, CHASING, ATTACKING, STUNNED, FLEEING, DEAD }
enum EnemyFacingMode { TARGET, MOVEMENT, COMMAND, FIXED, SPIN }
enum EnemyRole { FIGHTER, CARGO, MINER, SUPPORT } 
enum EnemyClass { LIGHT, STANDARD, HEAVY, CAPITAL } 
enum EnemyRank { COMMON, ELITE, MINIBOSS, BOSS }
enum EnemyRemovalReason { KILLED, ESCAPED, DESPAWNED }

//==================================================
// ATTACK CONTROLLER
//==================================================
enum AttackSelection { SEQUENTIAL, RANDOM, WEIGHTED }
enum EnemyAttackPhase { IDLE, TELEGRAPH, ACTIVE, COOLDOWN }
enum AttackDelivery { PROJECTILE, AREA, BEAM }
enum AttackAreaShape { CIRCLE, CAPSULE, CONE }
enum AimMode { MOUNT, TARGET, TARGET_LEAD, WORLD }
enum ShotPattern { SINGLE, SPREAD, RANDOM_CONE }
//==================================================
// HARDPOINTS / WEAPON MOUNTS
//==================================================
enum WeaponMountMode { HARDPOINT, CENTRE }
enum HardpointFireOrder { ALL, SEQUENTIAL, RANDOM }
enum HardpointRotation { FIXED, TARGET }
//==================================================
// PROJECTILES
//==================================================
enum ProjectileMotion { STANDARD, ROCKET, CURVE, STATIONARY }
enum ProjectileClass { LIGHT, REGULAR, HEAVY }
enum ProjectileState { ACTIVE, RICOCHET }
//==================================================
// DAMAGE / DEFENCE
//==================================================
enum DamageType { KINETIC, ENERGY, EXPLOSIVE, ELECTRIC, THERMAL, CORROSIVE }
enum DamageEffect { NONE, DISRUPTION, BURN, CORROSION, STAGGER }
enum DefenceLayer { NONE, SHIELD, ARMOUR, HULL }
//==================================================
// RESOURCES
//==================================================
enum ResourceType { NONE, ENERGY, FUEL, BULLETS, EXPLOSIVES }

enum AsteroidSize { SMALL, MEDIUM, LARGE }
enum AsteroidResponse { IGNORE, AVOID, STOP, DESTROY }