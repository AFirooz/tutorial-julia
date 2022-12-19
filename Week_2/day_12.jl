function find_neighbours(point, max_indices)
    neighbours = Vector{Vector{Int64}}()
    for Δ in -1:2:1  # Yes I have just remembered I could use greek letters like this
        push!(neighbours, [point[1] + Δ, point[2]])
        push!(neighbours, [point[1], point[2] + Δ])
    end

    # Filter out values that are not within limits of array
    neighbours = [neighbour for neighbour in neighbours if all(x->x>=1, neighbour)]
    for i in 1:2
        neighbours = [neighbour for neighbour in neighbours if neighbour[i] <= max_indices[i]]
    end
    return neighbours
end

function traverse_region(A::Array)
    global step_count = fill(prod(size(A)), size(A))  # Fill step count with maximal values
    visited = zeros(size(A));
    queue = Vector{Vector{Int64}}()
    start_point = findfirst(x->x=='S', A);

    visited[start_point] = 1  # Mark source as visited
    step_count[start_point] = 0
    A[start_point] = 'a'; A[findfirst(x->x=='E', A)] = 'z'
    push!(queue, Vector([start_point[i] for i in 1:2]))

    while length(queue) > 0
        point_coords = popfirst!(queue)
        neighbours = find_neighbours(point_coords, size(A))

        for neighbour in neighbours
            if Int(only(A[neighbour...])) - Int(only(A[point_coords...])) > 1
                continue  # Skip this point as inaccessible
            end

            if step_count[neighbour...] > step_count[point_coords...] + 1
                step_count[neighbour...] = step_count[point_coords...] + 1
            end

            if visited[neighbour...] == 0
                push!(queue, neighbour)
                visited[neighbour...] = 1
            end
        end
    end
    return step_count
end


open("Week_2/Inputs/day_12.txt", "r") do f
    # Read in altitudes (very glad I have written this for day 8 already)
    lines = readlines(f)
    heights = Array{Char}(undef, length(lines), length(lines[1]))
    for (i, line) in enumerate(lines)
        for (j, val) in enumerate(line)
            heights[i, j] = val
        end
    end

    end_point = findfirst(x->x=='E', heights)
    step_counts = traverse_region(heights)
    
    # Part B - Consider any other points on altitude 'a'
    shortest_routes = Vector{Int64}()
    for equiv_start_loc in findall(x->x=='a', heights)
        heights[equiv_start_loc] = 'S'
        heights[end_point] = 'E'

        alt_step_counts = traverse_region(heights)
        push!(shortest_routes, alt_step_counts[end_point])
    end
                
    println("Minimum number of steps from original start point: $(step_counts[end_point])")
    println("Minimum number of steps from same altitude start point: $(minimum(shortest_routes))")
end
