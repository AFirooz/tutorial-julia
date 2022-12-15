function draw_lines(line_coords, A, x_offset)
    # If you get an indexing error then we should increase bounds
    for i in eachindex(line_coords)[2:end]
        if line_coords[i-1][1] == line_coords[i][1]  # Vertical line
            line_sign = sign(line_coords[i][2]-line_coords[i-1][2])
            for y in line_coords[i-1][2]:line_sign:line_coords[i][2]
                A[line_coords[i][1] - x_offset, y + 1] = 'X'
            end
        end

        if line_coords[i-1][2] == line_coords[i][2]  # Horizontal line
            line_sign = sign(line_coords[i][1]-line_coords[i-1][1])
            for x in line_coords[i-1][1]:line_sign:line_coords[i][1]
                A[x - x_offset, line_coords[i][2] + 1] = 'X'  
            end
        end
    end 
    A[500-x_offset, 1] = 'S'  # Location of Source
end

function print_array(A::Array{Char})
    for n in 1:size(A)[1]  # Each line
        for m in 1:size(A)[2]
            print(A[n, m])
        end
        print("\n")
    end
end

function drop_sand(A::Array{Char}, x_offset::Int)
    # Will return updated matrix A with settled sand_count
    # Throws a bounds error when sand overflows or hits source
    pos = [500 - x_offset, 1]
    while true
        if A[pos...] == 'o'
            throw(BoundsError())  # Source is blocked so nowhere in matrix for sand to flow
        elseif A[pos[1], pos[2] + 1] == '.'  # Empty space below
            pos = [pos[1], pos[2] + 1]
        elseif A[pos[1] - 1, pos[2] + 1] == '.'  # Diagonal left
            pos = [pos[1] - 1, pos[2] + 1]
        elseif A[pos[1] + 1, pos[2] + 1] == '.'  # Diagonal right
            pos = [pos[1] + 1, pos[2] + 1] 
        else
            A[pos...] = 'o'  # Sand settles
            return A
        end
    end
end

function simulate_sand(caves, x_offset)
    sand_count = 0;
    while true
        try
            drop_sand(caves, x_offset)
            # print_array(permutedims(caves))
        catch BoundsError
            break
        end
        sand_count += 1
    end
    return sand_count
end


open("Week_2/Inputs/day_14.txt", "r") do f
    caves = fill('.', (2000, 200))  # Extend this range as necessary to be safe
    x_offset = 0; max_y = 0
    lines = readlines(f)
    for line in lines
        rock_lines = split(line, " -> ")
        line_coords = Vector()
        for point in rock_lines
            point_coords = map(x -> parse(Int, x), split(point, ','))
            push!(line_coords, point_coords)
            if point_coords[2] > max_y
                max_y = point_coords[2]
            end
        end
        draw_lines(line_coords, caves, x_offset)
    end
    # print_array(permutedims(caves))  # Draw with [x, y] but array indexing naturally has [y, x]
   
    # Part A
    caves_a = deepcopy(caves)
    sand_count = simulate_sand(caves_a, x_offset)
    println("Total accumulated sand without floor: $sand_count")

    # Part B
    floor_line = Vector([[x_offset + 1, max_y + 2], [size(caves)[1] + x_offset, max_y + 2]])
    draw_lines(floor_line, caves, x_offset)
    sand_count_b = simulate_sand(caves, x_offset)
    println("Total accumulated sand with floor: $sand_count_b")
end