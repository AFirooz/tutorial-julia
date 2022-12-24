using ProgressBars

function get_pattern(x, y, rock_num)
    patterns = Vector([
        Set([[x, y], [x+1, y], [x+2, y], [x+3, y]]),
        Set([[x+1, y], [x, y+1], [x+1, y+1], [x+1, y+2], [x+2, y+1]]),
        Set([[x, y], [x+1, y], [x+2, y], [x+2, y+1], [x+2, y+2]]),
        Set([[x, y], [x, y+1], [x, y+2], [x, y+3]]),
        Set([[x, y], [x+1, y], [x, y+1], [x+1. y+1]])
    ])
    return patterns[((rock_num - 1) % 5) + 1]  # Awkward conversion to 1-indexing
end

function get_height(chamber)
    col_heights = [map(col -> findlast(x -> x==1, col), chamber)..., 0]  # Add zero if no elements
    maximum(filter(x-> !isa(x, Nothing),col_heights))

end

function seed_rock(chamber, rock_num)
    height = get_height(chamber) + 4
    pattern = get_pattern(3, height, rock_num)

    # Add rows to chamber if required
    pattern_top = maximum([pos[2] for pos in pattern])
    if length(chamber[1]) < pattern_top
        for _ in 1:(pattern_top - length(chamber[1]))
            for col in chamber
                push!(col, 0)
            end
        end
    end

    # Seed pattern within chamber
    for point in pattern
        chamber[Int(point[1])][Int(point[2])] = 2
    end
    return chamber
end

function find_falling_pattern(chamber)
    pattern = Vector()
    for (i, col) in enumerate(chamber)
        y_vals = findall(x -> x==2, col)
        for val in y_vals
            push!(pattern, [i, val])
        end
    end
    return pattern
end

function step_shifting_rock(chamber, time, wind_list)
    winds = Dict('<' => -1, '>' => 1)
    windex = ((time - 1) % length(wind_list)) + 1  # I hate indexing from one
    wind_shift = winds[wind_list[windex]]
    shift_pattern = find_falling_pattern(chamber)
    new_chamber = deepcopy(chamber)

    try
        for point in shift_pattern  # If movement allowed, erase old block
            if chamber[point[1] + wind_shift][point[2]] == 1
                throw(BoundsError)  # Stuck against static block
            end
            new_chamber[point[1]][point[2]] = 0
        end
        for point in shift_pattern  # Draw new block
            new_chamber[point[1] + wind_shift][point[2]] = 2
        end
    catch BoundsError  # Stuck against static block/walls
        new_chamber = chamber
    end
    return new_chamber
end

function step_falling_rock(chamber)
    # Falling step - BoundsError not handled as block is settled
    # This is different enough to justify duplicating code,
    # plus separating the two steps is necessary when catching errors
    new_chamber = deepcopy(chamber)
    fall_pattern = find_falling_pattern(chamber)
    for point in fall_pattern
        if chamber[point[1]][point[2] - 1] == 1
            throw(BoundsError)  # Stuck against static block
        end
        new_chamber[point[1]][point[2]] = 0
    end
    for point in fall_pattern
        new_chamber[point[1]][point[2] - 1] = 2
    end
    return new_chamber
end

function print_chamber(chamber)
    char_map = Dict(0 => '.', 1 => '#', 2 => '@')
    for y in reverse(eachindex(chamber[1]))
        print('|')
        for x in eachindex(chamber)
            print(char_map[chamber[x][y]])
        end
        println('|')
    end
    println("+-------+\n")
end

function simulate_rocks(n_steps, wind_pattern)
    global chamber = Vector([[] for _ in 1:7])

    time = 1
    for n in ProgressBar(1:n_steps)
        global chamber = seed_rock(chamber, n)
        while true
            global chamber = step_shifting_rock(chamber, time, wind_pattern)
            time += 1
            try
                global chamber = step_falling_rock(chamber)
            catch BoundsError
                global chamber = map(col -> replace(col, 2=>1), chamber)
                break
            end
        end
        if time % length(wind_pattern) == 0
            println("Complete wind cycle after $n rocks")
        end
    end
    return get_height(chamber)
end

function simulate_rocks_b(n_steps, wind_pattern)
    time = 1
    rock_n = 1
    states = Vector()
    
    global chamber = Vector([[] for _ in 1:7])
    global cycle_search = true
    global final_rock = Inf

    while rock_n <= final_rock
        global chamber = seed_rock(chamber, rock_n)
        while true
            global chamber = step_shifting_rock(chamber, time, wind_pattern)
            time += 1
            try
                global chamber = step_falling_rock(chamber)
            catch BoundsError
                global chamber = map(col -> replace(col, 2=>1), chamber)
                break
            end
        end
        state = [(time-1) % length(wind_pattern), (rock_n-1) % 5]
        if cycle_search && (state in states)
            global start_rock = findfirst(x -> x==state, states)
            global end_height = get_height(chamber)
            global n_cycles = fld((n_steps - start_rock), (rock_n - start_rock))
            global final_rock = (n_steps - start_rock - (rock_n - start_rock) * n_cycles) + rock_n
            global cycle_search = false
        end
        push!(states, state)
        rock_n += 1
    end
    buffer_height = get_height(chamber) - end_height
    initial_height = simulate_rocks(start_rock, wind_pattern)
    cycle_height = end_height - initial_height
    total_height = initial_height + (n_cycles * cycle_height) + buffer_height
    return total_height
end


open("Week_3/Inputs/day_17.txt", "r") do f
    global wind_pattern = readlines(f)[1]
end

height_after_2022_steps = simulate_rocks(2022, wind_pattern)
println("Max height after 2022 rocks: $height_after_2022_steps")

# This will be periodic over some N rocks, where N is divisible by 5 and 
# repeats after length(wind_pattern) full wind cycles. Unfortunately there
# is not a set number of cycles per block, so this is non-trivial to compute.
# We must detect when a repeated state is obtained.

tot_steps = 1000000000000
tot_height = simulate_rocks_b(tot_steps, wind_pattern)
println("Max height after $tot_steps rocks: $tot_height")
