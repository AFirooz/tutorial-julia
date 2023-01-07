function wrap_around_board(board, pos)
    # Go backwards (-dir) across board until pos is no longer valid
    while true
        pos[1:2] -= pos[3]
        try
            if board[pos[1]][pos[2]] == ' '
                break  # Found valid pos
            end
        catch BoundsError
            break  # Reached edge of board
        end
    end
    pos[1:2] += pos[3]  # Take one step back to valid location
    return pos
end

function wrap_around_cube(board, pos)
    # Implementing cube surface as in full input, won't work for example!
    # Considering wrapping at map adges, based on marcodelmastro's approach
    # This hardcoding is not ideal, but realistically my only option at this point in the year
    
    pos[1], pos[2] = mod(pos[1], 1:length(board)), mod(pos[2], 1:length(board[1]))
    # SQUARE (1) - top of (1) goes into left of (6)
    if 51 <= pos[2] <= 100 && pos[1] == 200 && pos[3] == [-1, 0]
        pos = [pos[2] + 100, 1, [0, 1]]
    # Left of (1) goes into left of (4) reversed
    elseif pos[2] == 50 && 1 <= pos[1] <= 50 && pos[3] == [0, -1]
        pos = [151 - pos[1], 1, [0, 1]]  #todo
    # SQUARE (2) - top of (2) goes into bottom of (6)
    elseif 101 <= pos[2] <= 200 && pos[1] == 200 && pos[3] == [-1, 0]
        pos = [pos[1], pos[2] - 100, [-1, 0]]
    # Bottom of (2) goes into right of (3)
    elseif 101 <= pos[2] <= 200 && pos[1] == 51 && pos[3] == [1, 0]
        pos = [pos[2] - 50, 100, [0, -1]]
    # Right of (2) goes into right of (5) reversed
    elseif pos[2] == 1 && 1 <= pos[1] <= 50 && pos[3] == [0, 1]
        pos = [151 - pos[1], 100, [0, -1]]
    # SQUARE (3) - left of (3) goes into top of (4) 
    elseif pos[2] == 50 && 51 <= pos[1] <= 100 && pos[3] == [0, -1]
        pos = [101, pos[1] - 50, [1, 0]]
    # Right of (3) goes into bottom of (2)
    elseif pos[2] == 101 && 51 <= pos[1] <= 100 && pos[3] == [0, 1]
        pos = [50, pos[1] + 50, [-1, 0]]
    # SQUARE (4) - top of (4) goes into left of (3)
    elseif 1 <= pos[2] <= 50 && pos[1] == 100 && pos[3] == [-1, 0]
        pos = [pos[2] + 50, 51, [0, 1]]
    # Left of (4) goes into right of (1) reversed
    elseif pos[2] == 150 && 101 <= pos[1] <= 150 && pos[3] == [0, -1]
        pos = [151 - pos[1], 51, [0, 1]]
    # SQUARE (5) - right of (5) goes into left of (2) reversed
    elseif pos[2] == 101 && 101 <= pos[1] <= 150 && pos[3] == [0, 1]
        pos = [151 - pos[1], 150, [0, -1]]
    # Bottom of (5) goes into right of (6)
    elseif 51 <= pos[2] <= 100 && pos[1] == 151 && pos[3] == [1, 0]
        pos = [pos[2] + 100, 50, [0, -1]]
    # SQUARE (6) - left of (6) goes into top of (1)
    elseif pos[2] == 150 && 151 <= pos[1] <= 200 && pos[3] == [0, -1]
        pos = [1, pos[1] - 100, [1, 0]]
    # Right of (6) goes into bottom of (5)
    elseif pos[2] == 51 && 151 <= pos[1] <= 200 && pos[3] == [0, 1]
        pos = [150, pos[1] - 100, [-1, 0]]
    # Bottom of (6) goes into top of (2)
    elseif 1 <= pos[2] <= 50 && pos[1] == 1 && pos[3] == [1, 0]
        pos = [1, pos[2] + 100, [1, 0]]
    end
end

function step_pos(board, pos, instr, wrapping_func)
    for _ in 1:instr  # One step at a time
        new_pos = [(pos[1:2] + pos[3])..., pos[3]]
        try  # Wrap board if we go into space on board, or off the edge of board
            if board[new_pos[1]][new_pos[2]] == ' '  
                new_pos = wrapping_func(board, new_pos)
            end
        catch BoundsError
            new_pos = wrapping_func(board, new_pos)
        end

        if board[new_pos[1]][new_pos[2]] == '#'
            break # If you hit a wall, break
        elseif board[new_pos[1]][new_pos[2]] == '.'
            pos = new_pos  # Move to new valid location
            continue
        else  # Character in proposed location is not recognised
            println(("Variable $(board[new_pos[1]][new_pos[2]]) unknown"))
            throw(UndefRefError)
        end
    end
    return pos
end

function rotate_pos(pos, rot_dir)
    rotation_dirs = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    dir_map = Dict("R" => 1, "L" => -1)

    curr_dir = findfirst(val -> val==pos[3], rotation_dirs)
    pos[3] = rotation_dirs[mod(curr_dir + dir_map[rot_dir], 1:4)]
    return pos
end

function execute_instr(board, pos, instr, wrapping_func)
    if occursin(r"[0-9]+", instr)  # Movement
        pos = step_pos(board, pos, parse(Int, instr), wrapping_func)
    else  # Rotation
        pos = rotate_pos(pos, instr)
    end
end

function trace_route(board, pos, instructions, wrapping_func)
    for instr in instructions
        pos = execute_instr(board, pos, instr, wrapping_func)
    end
    return pos
end

function score_pos(pos)
    facing_score = Dict([0, 1] => 0, [1, 0] => 1, [0, -1] => 2, [-1, 0] => 3)
    return 1000 * pos[1] + 4 * pos[2] + facing_score[pos[3]]
end

open("Week_4/Inputs/day_22.txt", "r") do f
    global board, instructions = [x for x in split(read(f, String), "\r\n\r\n")]
end

# Generate board, and pad so every line is the same length
board = split(board, "\r\n")
longest_line = maximum([length(line) for line in board])
board = map(line -> line * repeat(' ', longest_line - length(line)), board)

# Split instruction string into individual movements
rg = r"([A-Z]+)|([0-9]+)"
instructions = [match.match for match in collect(eachmatch(rg, instructions))]

# Define position in form (y, x, dir) where dir is the (y, x) change from step in current direction
start_pos = [1, findfirst(x -> x=='.', board[1]), [0, 1]]
final_pos_a = trace_route(board, copy(start_pos), instructions, wrap_around_board)
println("Score of the final position in 2D is: $(score_pos(final_pos_a))")

# For Part B, use a different wrapping function
final_pos_b = trace_route(board, start_pos, instructions, wrap_around_cube)
println("Score of the final position in 3D is: $(score_pos(final_pos_b))")
