local FilePath = require('wgc.file_path')

local path1 = FilePath:new()
path1:set_state('path one')

local path2 = FilePath:new()
path2:set_state('path two')

print(string.format("Path1 [%s], Path2 [%s]", 
path1:get_state(), 
path2:get_state()))

print(string.format("Path1 [%s], Path2 [%s]", 
path1.value, 
path2.value))

print(string.format("Path1 [%s], Path2 [%s]", 
FilePath.value, 
FilePath.value))
