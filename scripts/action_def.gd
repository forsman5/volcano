class_name ActionDef
extends RefCounted

enum TargetType { AUTO_WEAPON, SELF, TARGETED_ENEMY }
enum Effect { NONE, DEFEND, TAUNT }

var name: String = ""
var targeting: TargetType = TargetType.AUTO_WEAPON
var effect: Effect = Effect.NONE
