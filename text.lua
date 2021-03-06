-- String helpers - split & trim at end & begin
function upper_first(str)
    return str:sub(1,1):upper()..str:sub(2)
end
function lower_first(str)
    return str:sub(1,1):lower()..str:sub(2)
end
function starts_with(str, start) return str:sub(1, start:len()) == start end
function ends_with(str, suffix)
    return str:sub(str:len() - suffix:len() + 1) == suffix
end
function trim(str, to_remove)
    local j = 1
    for i = 1, string.len(str) do
        if str:sub(i, i) ~= to_remove then
            j = i
            break
        end
    end

    local k = 1
    for i = string.len(str), j, -1 do
        if str:sub(i, i) ~= to_remove then
            k = i
            break
        end
    end

    return str:sub(j, k)
end

function trim_begin(str, to_remove)
    local j = 1
    for i = 1, string.len(str) do
        if str:sub(i, i) ~= to_remove then
            j = i
            break
        end
    end

    return str:sub(j)
end

trim_left = trim_begin

function trim_end(str, to_remove)
    local k = 1
    for i = string.len(str), 1, -1 do
        if str:sub(i, i) ~= to_remove then
            k = i
            break
        end
    end
    return str:sub(1, k)
end

trim_right = trim_end

function split(str, delim, limit, regex)
    if not limit then return split_without_limit(str, delim, regex) end
    local no_regex = not regex
    local parts = {}
    local occurences = 1
    local last_index = 1
    local index = string.find(str, delim, 1, no_regex)
    while index and occurences < limit do
        table.insert(parts, string.sub(str, last_index, index - 1))
        last_index = index + string.len(delim)
        index = string.find(str, delim, index + string.len(delim), no_regex)
        occurences = occurences + 1
    end
    table.insert(parts, string.sub(str, last_index))
    return parts
end

function split_without_limit(str, delim, regex)
    local no_regex = not regex
    local parts = {}
    local last_index = 1
    local index = string.find(str, delim, 1, no_regex)
    while index do
        table.insert(parts, string.sub(str, last_index, index - 1))
        last_index = index + string.len(delim)
        index = string.find(str, delim, index + string.len(delim), no_regex)
    end
    table.insert(parts, string.sub(str, last_index))
    return parts
end

split_unlimited = split_without_limit

function split_lines(str, limit)
    modlib.text.split(str, "\r?\n", limit, true)
end

hashtag = string.byte("#")
zero = string.byte("0")
nine = string.byte("9")
letter_a = string.byte("A")
letter_f = string.byte("F")

function is_hexadecimal(byte)
    return (byte >= zero and byte <= nine) or
               (byte >= letter_a and byte <= letter_f)
end

magic_chars = {
    "%", "(", ")", ".", "+", "-", "*", "?", "[", "^", "$" --[[,":"]]
}

function escape_magic_chars(text)
    for _, magic_char in ipairs(magic_chars) do
        text = string.gsub(text, "%" .. magic_char, "%%" .. magic_char)
    end
    return text
end

function utf8(number)
    if number < 0x007F then return string.char(number) end
    if number < 0x00A0 or number > 0x10FFFF then -- Out of range
        return
    end
    local result = ""
    local i = 0
    while true do
        local remainder = number % 64
        result = string.char(128 + remainder) .. result
        number = (number - remainder) / 64
        i = i + 1
        if number <= math.pow(2, 8 - i - 2) then break end
    end
    return string.char(256 - math.pow(2, 8 - i - 1) + number) .. result -- 256 = math.pow(2, 8)
end

function handle_ifdefs(code, vars)
    local finalcode = {}
    local endif
    local after_endif = -1
    local ifdef_pos, after_ifdef = string.find(code, "--IFDEF", 1, true)
    while ifdef_pos do
        table.insert(finalcode,
                     string.sub(code, after_endif + 2, ifdef_pos - 1))
        local linebreak = string.find(code, "\n", after_ifdef + 1, true)
        local varname = string.sub(code, after_ifdef + 2, linebreak - 1)
        endif, after_endif = string.find(code, "--ENDIF", linebreak + 1, true)
        if not endif then break end
        if vars[varname] then
            table.insert(finalcode, string.sub(code, linebreak + 1, endif - 1))
        end
        ifdef_pos, after_ifdef = string.find(code, "--IFDEF",
                                               after_endif + 1, true)
    end
    table.insert(finalcode, string.sub(code, after_endif + 2))
    return table.concat(finalcode, "")
end
