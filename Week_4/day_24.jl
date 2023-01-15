using DataStructures

function my_gcd(val_1, val_2)
    # There are builtins for this, but Euler's method is pretty. Req val_1 <= val_2
    if val_1 == 0
        return val_2
    end
    return gcd(val_2 % val_1, val_1)
end

function my_lcm(val_1, val_2)
    return Int((val_1 * val_2) / my_gcd(sort([val_1, val_2])...))
end

function manhattan_dist(pos_1::Vector{Int}, pos_2::Vector{Int})
    # This is copied from day 15 - I could put together a library of these functions
    abs(pos_2[1] - pos_1[1]) + abs(pos_2[2] - pos_1[2])
end

function read_winds(lines)
    winds = Vector{Vector{Int8}}()
    # In form [x, y, dir], where dir ranges from 1 -> 4
    dir_map = Dict('^' => 1, '>' => 2, 'v' => 3, '<' => 4)
    for (i, line) in enumerate(lines[2:end - 1])
        for (j, char) in enumerate(line[2: end - 1])
            if char != '.'
                push!(winds, [i, j, dir_map[char]])
            end
        end
    end
    return winds
end

function new_wind_pos(pos, step, bounds)
    new_pos = pos + step
    return [mod(x, 1:bounds[i]) for (i, x) in enumerate(new_pos)]
end

function step_winds(winds, bounds)
    step_dirs = Vector{Vector{Int8}}([[-1, 0], [0, 1], [1, 0], [0, -1]])
    new_winds = Vector{Vector{Int8}}()
    for wind in winds
        push!(new_winds, [new_wind_pos(wind[1:2], step_dirs[wind[3]], bounds)..., wind[3]])
    end
    return new_winds
end

function construct_wind_map(winds, arr_slice)
    fill!(arr_slice, false)  # Default to having no winds
    for wind in winds
        arr_slice[wind[1: 2]...] = true
    end
    return arr_slice
end

function construct_wind_array(winds, bounds)
    # Wind repeats every N steps (where N is the LCM of region bounds)
    # These patterns will be stored in an array of depth N to be accessed easily
    # I learnt from yesterday - this is quicker than a list to search in!
    t_steps = my_lcm(bounds...)
    arr = Array{Bool, 3}(undef, bounds..., t_steps)
    for t in 1:t_steps
        arr[:, :, t] = construct_wind_map(winds, arr[:, :, t])
        winds = step_winds(winds, bounds)
    end
    return arr
end

function find_available_steps(pos, time, wind_arr)
    # Check movement is in region, and doesn't coincide with windy cell
    pos_steps = [pos + step for step in [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]]]
    filter!(pos -> all([1 <= x <= size(wind_arr)[i] for (i, x) in enumerate(pos)]), pos_steps)
    filter(pos -> !wind_arr[(pos)..., mod(time + 2, 1:size(wind_arr)[3])], pos_steps)
    # +2: +1 because we need wind one step into future, +1 because index 1 of array corresponds to time zero
end  # Returns output of second filter

function a_star_search(start_pos, end_pos, start_time, wind_array)
    # Used instead of BFS with priority queue to focus on paths that progress to target
    first_state = Vector([start_pos..., start_time])
    curr_score = DefaultDict{Vector{Int16}, Int16}(typemax(Int16))  # Used instead of Inf16 as julia has no integer inf type
    curr_score[first_state] = 0

    # Predicted score = (current score from start to pos) + (predicted score from pos to end)
    pred_reward = pos -> manhattan_dist(pos, end_pos)
    pred_score = DefaultDict{Vector{Int16}, Int16}(typemax(Int16))
    pred_score[first_state] = pred_reward(start_pos)

    queue = PriorityQueue{Vector{Int16}, Int16}(first_state => pred_score[first_state])
    for i in 1:20  # Allow for waiting before start - upper limit is arbitrary
        state = first_state + [0, 0, i]
        curr_score[state] = i
        pred_score[state] = pred_reward(start_pos) + i
        enqueue!(queue, state => pred_score[state])
    end

    while length(queue) > 0
        state = dequeue!(queue)
        if state[1:2] == end_pos
            return state[3]
        end

        for new_pos in find_available_steps(state[1:2], state[3], wind_array)
            new_state = Vector([new_pos..., state[3] + 1])
            if curr_score[state] + 1 < curr_score[new_state]
                curr_score[new_state] = curr_score[state] + 1
                pred_score[new_state] = curr_score[new_state] + pred_reward(new_pos)
                if new_state ∉ keys(queue)
                    enqueue!(queue, new_state => pred_score[new_state])
                end
            end
        end
    end
    @warn("Terminated A-star search with empty queue before reaching target")
end

function map_path(start_pos, end_pos, start_time, wind_array)
    time = a_star_search(start_pos, end_pos, start_time, wind_array,)
    return time + 1  # Inc step to exit wind region
end


open("Week_4/Inputs/day_24.txt", "r") do f
    global lines = readlines(f)
end

# All indexes are within the hashed area
start_pos = [1, findfirst(".", lines[1])[1] - 1]
end_pos = [length(lines) - 2, findfirst(".", lines[end])[1] - 1]

winds = read_winds(lines)
wind_array = construct_wind_array(winds, [length(lines) - 2, length(lines[1]) - 2])

first_trip = map_path(start_pos, end_pos, 1, wind_array)
return_trip = map_path(end_pos, start_pos, first_trip + 1, wind_array)
third_trip = map_path(start_pos, end_pos, return_trip + 1, wind_array)

println("Time to traverse network once: $first_trip")
println("Time to traverse network thrice, going back for snacks: $third_trip")
