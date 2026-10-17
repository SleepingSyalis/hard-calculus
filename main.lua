local rate = 44100
local duration = 10

local env = {
    x = 0,
    sin = math.sin,
    cos = math.cos,
    tan = math.tan,
    pi = math.pi,
    exp = math.exp,
    floor = math.floor,
    random = math.random,
    abs = math.abs,
}

local function save(path, samples)
    local file, err = io.open(path, "wb")
    if not file then
        print(err)
        return
    end

    local n = #samples

    file:write(string.pack("<c4I4c4c4I4I2I2I4I4I2I2c4I4",
                            "RIFF",
                            36 + n * 2,
                            "WAVE",
                            "fmt ",
                            16,
                            1,
                            1,
                            rate,
                            rate * 2,
                            2,
                            16,
                            "data",
                            n * 2
                        )
                )

    for i = 1, n do -- TODO pack chunks
        local y = samples[i]
        if y > 1 then
            y = 1
        elseif y < -1 then
            y = -1
        end

        file:write(string.pack("<i2", math.floor(y * 32767 + 0.5)))
    end

    file:close()
end

io.write("f(x) = ")
local input = io.read()

local f, err = load("return " .. input, "f", "t", env)
if not f then
    print(err)
    return
end

local samples = {}

for i = 1, rate * duration do
    env.x = (i - 1) / rate

    local success, result = pcall(f)
    if success then
        table.insert(samples, result)
    else
        print(result)
        return
    end
end
save("tone.wav", samples)