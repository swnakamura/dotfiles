# config.fishで定義されているIS_MACOSはここではまだ定義されていないので使えない
if test (uname) = Darwin
    set pathtozlua $(brew --prefix z.lua)/share/z.lua/z.lua
else
    set pathtozlua /usr/share/z.lua/z.lua
end

lua $pathtozlua --init fish | source
