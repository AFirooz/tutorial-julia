function snafu_to_int(snafu::String)
    # Conversion from a base 5 (with chars for -2 to 2) number called SNAFU into base 10 int
    digits = split(snafu, "")
    digit_map = Dict("=" => -2, "-" => -1, "0" => 0, "1" => 1, "2" => 2)
    num = 0
    for (i, digit) in enumerate(reverse(digits))
        num += digit_map[digit] * 5 ^ (i-1)
    end
    return num
end

function int_to_snafu(num::Int)
    snafu_map = Dict(-2 => "=", -1 => "-", 0 => "0", 1 => "1", 2 => "2")
    snafu = [snafu_map[mod(num % 5^1, -2:2)]]  # Units character
    n = 1
    while true
        offset = sum([2 * 5^(i-1) for i in 1:n])
        if offset >= num
            break
        end
        new_num = (num + offset) ÷ 5^n
        pushfirst!(snafu, snafu_map[mod(new_num % 5^n, -2:2)])
        n += 1
    end
    return join(snafu)
end


open("Week_4/Inputs/day_25.txt", "r") do f
    global snafu_nums = readlines(f)
end

summed_input = sum([snafu_to_int(num) for num in snafu_nums])
println("The sum in SNAFU is $(int_to_snafu(summed_input))")
