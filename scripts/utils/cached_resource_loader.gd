class_name CachedResourceLoader
extends RefCounted

var _cache := {}
var path_template: String


func _init(p_path_template: String) -> void:
	path_template = p_path_template


func get_cached(file_name: String) -> Resource:
	if not _cache.has(file_name):
		_cache[file_name] = load(path_template % file_name)
	return _cache[file_name]
