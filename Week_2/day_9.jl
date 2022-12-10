import LinearAlgebra: norm

function move_tail(curr_tail, new_head)
    # Also allows diagonal head movement for section B
    director = new_head - curr_tail
    if norm(director) >= 2  # I.e. adjacent knots don't touch
        curr_tail += sign.(director)
    end 
    return curr_tail
end

open("Week_2/Inputs/day_9.txt", "r") do f
    # SETUP 2 KNOT ROPE (PART A)
    head_pos = [0, 0]; tail_pos_a = [0, 0]
    tail_hist_a = Vector{Vector{Int}}()
    push!(tail_hist_a, tail_pos_a)

    # SETUP 10 KNOT ROPE (PART B)
    knot_pos_b = zeros(10, 2)
    tail_hist_b = Vector{Vector{Int}}()
    push!(tail_hist_b, knot_pos_b[10, :])

    moves = Dict("U" => [0, 1], "D" => [0, -1], "R" => [1, 0], "L" => [-1, 0])

    # RECORD MOTION OF KNOTS
    while ! eof(f)
        head_movement = split(readline(f), ' ')  # Gives direction, step number
        for n in 1:parse(Int8, head_movement[2])
            head_pos += moves[head_movement[1]]

            # UPDATE 2 KNOT TAIL
            tail_pos_a = move_tail(tail_pos_a, head_pos)
            push!(tail_hist_a, tail_pos_a)

            # UPDATE 10 KNOT TAIL
            knot_pos_b[1, :] += moves[head_movement[1]]
            for i in 2:10
                knot_pos_b[i, :] = move_tail(knot_pos_b[i, :], knot_pos_b[i-1, :])
            end
            push!(tail_hist_b, knot_pos_b[10, :])  # Record position of final knot only
        end
    end
    println("Number of locations tail visited (2 knots): $(length(unique(tail_hist_a)))")
    println("Number of locations tail visited (10 knots): $(length(unique(tail_hist_b)))")
end