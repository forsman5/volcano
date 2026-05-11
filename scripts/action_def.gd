class_name ActionDef
extends RefCounted

enum TargetType { AUTO_WEAPON, SELF }

var name: String = ""
var targeting: TargetType = TargetType.AUTO_WEAPON
