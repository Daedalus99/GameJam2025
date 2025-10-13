class_name HarvestableData
extends Resource

@export_category("Identity")
@export var id: StringName
@export var display_name: String

@export_category("Economy")
@export var base_value: int = 100                 # credits at t=0, neutral demand
@export var appraisal_mult: float = 1.0           # per-run appraisal modifier
@export var demand_tags: PackedStringArray = []   # e.g. ["heart","vital","cult"]

# freshness -> price multiplier = pow(0.5, age_sec / half_life_sec)
@export var freshness_half_life_sec: float = 60.0

# quality multipliers (override defaults per part if needed)
@export var quality_mul := {"Pristine":1.0, "Intact":0.85, "Nicked":0.7, "Ruined":0.1}

@export_category("Gameplay")
enum Tool { SCALPEL, SHEARS, SAW }
@export var required_tool: Tool = Tool.SCALPEL
@export var yield_min: int = 1
@export var yield_max: int = 1
@export var weight: float = 1.0                   # carry penalty
@export var fragility: float = 0.3                # chance to downgrade on mishandling 0..1
@export var contamination_sensitivity: float = 0.2
@export var hazard_on_rupture: StringName = &""   # e.g. &"acid_sac"
@export var stacks: bool = false
@export var max_stack: int = 1

@export_category("Presentation")
@export var icon: Texture2D
@export var sprite_2d: Texture2D                   # optional for 2D previews
@export var model_scene: PackedScene               # 3D pickup/held model
@export var minigame_scene: PackedScene            # extraction UI/scene

@export_category("Audio/VFX")
@export var sfx_extract: AudioStream
@export var sfx_pickup: AudioStream
@export var sfx_drop:   AudioStream
@export var vfx_extract: PackedScene               # optional particles at hotspot

# --- helpers (call from gameplay) ---
func price_now(age_sec: float, quality: String, demand_mult: float = 1.0, extra_appraisal: float = 1.0) -> int:
	var qmul = quality_mul.get(quality, 1.0)
	var fresh := pow(0.5, max(0.0, age_sec) / max(0.0001, freshness_half_life_sec))
	var val = base_value * qmul * fresh * demand_mult * appraisal_mult * extra_appraisal
	return int(round(val))

func choose_yield(rng := RandomNumberGenerator.new()) -> int:
	if yield_min >= yield_max: return max(1, yield_min)
	rng.randomize()
	return rng.randi_range(yield_min, yield_max)
