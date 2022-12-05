function move_crates_part_a(crates::Vector{Vector{Char}}, move::Vector{Int64})
    for i in 1:move[1]
        pushfirst!(crates[move[3]], crates[move[2]][1])
        deleteat!(crates[move[2]], 1)
    end
    return crates
end

function move_crates_part_b(crates::Vector{Vector{Char}}, move::Vector{Int64})
    for i in reverse(1:move[1])
        pushfirst!(crates[move[3]], crates[move[2]][i])
        deleteat!(crates[move[2]], i)
    end
    return crates
end

open("Week_1/Inputs/day_5.txt", "r") do f
    lines = readlines(f)

    # FIND NUMBER OF STACKS
    global n_stacks = 0
    global n_input_rows
    for (index, line) in enumerate(lines)
        vals = split(line, r"\s+")  # Split by whitespace
        vals = filter((x) -> x != "", vals)  # Remove spurious empty strings from split

        if all(occursin.(r"^\d+$", vals))  # Broadcast regex to check all strings in list are integer
            global n_stacks = parse(Int64, vals[end])
            global n_input_rows = index - 1
            break
        end
    end

    # GENERATE EMPTY NESTED LIST TO STORE CRATES
    # First element in each list is at the top
    crates = Vector{Vector{Char}}()
    for i = 1:n_stacks
        push!(crates, Vector{Char}())
    end
    
    # READ INPUT INTO NESTED LIST
    for line in lines[1:n_input_rows]
        for i in 1:n_stacks
            if line[4*i - 2] != ' '
                push!(crates[i], line[4*i - 2])
            end
        end
    end

    # CONDUCT REQUIRED MOVES
    for line in lines[n_input_rows + 3: end]
        move = [parse(Int64,match.match) for match in eachmatch(r"\d+", line)]
        crates = move_crates_part_b(crates, move)
    end

    # READ OFF CRATES AT TOP OF PILES
    for i in 1:n_stacks
        print(crates[i][1])
    end
    print("\n")

end