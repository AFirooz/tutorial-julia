using DataStructures

function wrap_new_index(old_index, value, list_length)
    new_index = old_index + Int(floor(value))
    mod(new_index, 1:list_length-1) 
end

function mix_list(vals, og_vals)
    for val in og_vals
        old_index = findfirst(x -> x == val, vals)
        new_index = wrap_new_index(old_index, val, length(vals))
        deleteat!(vals, old_index)
        insert!(vals, new_index, val)
    end
    return vals
end

function score_list(sorted_vals)
    zero_index = findfirst(x -> floor(x)==0, sorted_vals)
    target_nums = [1000, 2000, 3000]  # Given in question
    Int(sum(map(n -> floor(sorted_vals[((zero_index + n - 1) % length(sorted_vals)) + 1]), target_nums)))
end

open("Week_3/Inputs/day_20.txt", "r") do f
    global input_vals = [parse(Int, line) for line in readlines(f)]
end

# Sneaky trick - add index in decimals to make every number unique
part_a_vals = [(val + n * 10^-5) for (n, val) in enumerate(input_vals)]
println("Summed grove coordinates: $(score_list(mix_list(part_a_vals, copy(part_a_vals))))")

part_b_vals = [(811589153 * val + n * 10^-5) for (n, val) in enumerate(input_vals)]
part_b_copy = deepcopy(part_b_vals)
for _ in 1:10
    mix_list(part_b_vals, part_b_copy)
end
println("Modified grove coordinates: $(score_list(part_b_vals))")
