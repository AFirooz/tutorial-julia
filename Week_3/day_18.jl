function single_cube_open_faces(cube, cubes)
    single_cube_count = 0
    rel_neighbours = [[1,0,0], [-1,0,0], [0,1,0], [0,-1,0], [0,0,1], [0,0,-1]]
    for neighbour in rel_neighbours
        if (cube + neighbour) ∉ cubes
            single_cube_count += 1
        end
    end
    return single_cube_count
end

function count_open_faces(cubes, counting_func)
    open_faces = 0
    for cube in cubes
        open_faces += counting_func(cube, cubes)
    end
    return open_faces
end

function extreme_loc_outside_cube(cubes, func)
    # Find point that maximises func for each coord in cubes list
    [func([cube[i] for cube in cubes]...) for i in 1:3]
end

function check_loc_in_region(loc, min_loc, max_loc)
    # Region is defined in cartesian coords and bound by two points
    all([(min_loc[i] <= loc[i] <= max_loc[i]) for i in 1:3])
end

function flood_cube_region(cubes)
    # Find all positions around cube that are touched by water
    min_loc = extreme_loc_outside_cube(cubes, min) - [1,1,1]
    max_loc = extreme_loc_outside_cube(cubes, max) + [1,1,1]

    flood_loc = Vector()
    next_flood_pos = Vector([min_loc])
    steps = [[1,0,0], [-1,0,0], [0,1,0], [0,-1,0], [0,0,1], [0,0,-1]]
    while max_loc ∉ flood_loc
        update_next_pos = Vector()
        for pos in next_flood_pos
            for step in steps
                if (check_loc_in_region(pos + step, min_loc, max_loc)
                    && (pos + step) ∉ cubes)
                    push!(update_next_pos, pos + step)
                end
            end
            push!(flood_loc, pos)
        end
        next_flood_pos = unique(update_next_pos)
    end
    return flood_loc
end

function single_cube_external_faces(cube, cubes)
    single_cube_count = 0
    rel_neighbours = [[1,0,0], [-1,0,0], [0,1,0], [0,-1,0], [0,0,1], [0,0,-1]]
    for neighbour in rel_neighbours
        if ((cube + neighbour) ∉ cubes) && ((cube + neighbour) ∈ flood)
            single_cube_count += 1
        end
    end
    return single_cube_count
end


open("Week_3/Inputs/day_18.txt", "r") do f
    global cubes = [[parse(Int8, val) for val in split(line, ",")] for line in readlines(f)]
end

println("Number of open faces: $(count_open_faces(cubes, single_cube_open_faces))")

flood = flood_cube_region(cubes)   
println("Number of external faces: $(count_open_faces(cubes, single_cube_external_faces))")
