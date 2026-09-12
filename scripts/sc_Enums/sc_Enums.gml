//==================================================
// GAME / FLOW STATES
//==================================================
enum GameState { BOOT, MENU, PLAYING, PAUSED, GAME_OVER }
enum LevelState { NONE, INITIALIZING, SHIP_SELECT, PLAYING, DEBUG, COMPLETE, FAILED, EXITING }
enum PlayerState { INITIALIZING, ACTIVE, DASHING, STUNNED, INVENTORY, FACILITY, DERELICT, DISABLED, DESTROYED }
enum BossEncounterState { WAITING, APPROACH, WAVE, BOSS, VICTORY }
//==================================================
// UI / MENU
//==================================================
enum InventoryTab { CARGO, EQUIPMENT, SYSTEMS, UPGRADES, NAVIGATION, LOG, STATISTICS}
enum MainMenuAction { DEPLOY, HANGAR, OPTIONS, CHANGE_PROFILE, EXIT }
enum GUIButtonStyle { STANDARD, TAB, PRIMARY, DANGER }
enum HudTopBannerMode { NONE, ENEMY, ALERT, DISCOVERY }
//==================================================
// FACTIONS / ENEMY STATE
//==================================================
enum Faction { PLAYER, SIMULANT, REBEL, CORPORATION, ALIEN, AUTOMATED }
enum EnemyState { IDLE, INVESTIGATING, CHASING, ATTACKING, STUNNED, RETREATING, FLEEING, DEAD }
enum EnemyCriticalResponse { RETREAT, FLEE, KAMIKAZE, SUICIDE, BERSERK }
enum EnemyFacingMode { TARGET, MOVEMENT, COMMAND, FIXED, SPIN }
enum EnemyRole { FIGHTER, CARGO, MINER, SUPPORT } 
enum EnemyClass {TINY, LIGHT, STANDARD, HEAVY, SUPERHEAVY, CAPITAL, TITAN } 
enum EnemyRank { COMMON, VETERAN, ELITE, CHAMPION, MINIBOSS, BOSS }
enum EnemyRemovalReason { KILLED, ESCAPED, DESPAWNED }
enum AsteroidResponse { IGNORE, AVOID, STOP, DESTROY, BOMBARD }
enum EnemyTerritoryType { NONE, RADIUS, ASTEROID_REGION, INSTANCE_RADIUS }
enum EnemyTerritoryFallback { NONE, FIND_REGION, ALLY_ANCHOR, FLEE }

//==================================================
// ATTACK CONTROLLER
//==================================================
enum AttackSelection { SEQUENTIAL, RANDOM, WEIGHTED }
enum EnemyAttackPhase { IDLE, TELEGRAPH, ACTIVE, COOLDOWN }
enum AttackDelivery { PROJECTILE, AREA, BEAM, DEPLOYABLE }
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
enum MineState
{
    ARMING,
    ARMED,
    TRIGGERED,
    DETONATED
}
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

enum AsteroidSize { SMALL, MEDIUM, LARGE, HUGE}
enum AsteroidFieldScale { SMALL, MEDIUM, LARGE }
enum AsteroidFieldDensity { SPARSE, STANDARD, DENSE }
enum AsteroidFieldShape { ORGANIC, BAND, RING, ARC }
enum AsteroidFieldDistribution { UNIFORM, DENSE_CORE, CLUSTERED, EDGE_HEAVY }

enum EnvironmentFieldType { GAS, ELECTRIC }

enum StructureCollisionShape { CIRCLE, RECTANGLE }

enum ItemLayer { RAW, MATERIAL, PART, PRODUCT }
enum ItemType { RESOURCE, STRUCTURAL, MECHANICAL, ELECTRICAL, AMMUNITION, MODULE, DRONE, WEAPON, DEVICE }
enum ItemGrade { COMMON, IMPROVED, ADVANCED, SUPERIOR, PROTOTYPE }
enum ModuleSlot { ARMOUR, SHIELD, REACTOR, THRUSTER, TARGETING, UTILITY, AUXILIARY }
enum FacilityService { REFINERY, FABRICATOR, REPAIR }

enum DerelictState { UNKNOWN, SCANNING, REVEALED, DEPLETED, DESTROYED }
enum DroneRole { SCANNER, SCOUT, REPAIR, MINING, SALVAGE, COMBAT }
enum DroneState { TRAVELLING, WORKING, RETURNING }
