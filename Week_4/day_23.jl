using ProgressBars, Profile

function read_elves(lines::Vector{String})
    # Store as list of coords rather than an array (as we don't know how big it should be)
    elves = Vector{Vector{Int16}}()  # Specifying int size for memory allocation boosts performance x4
    for (i, line) in enumerate(lines)
        for (j, val) in enumerate(line)
            if val == '#'
                push!(elves, [i, j])
            end
        end
    end
    return elves
end

function generate_elf_array(elves::Vector{Vector{Int16}})
    max_x, max_y = [max([pos[i] for pos in elves]...) for i in 1:2]
    min_x, min_y = [min([pos[i] for pos in elves]...) for i in 1:2]

    elf_arr = fill('.', (max_x-min_x+1, max_y-min_y+1))
    for elf in elves
        elf_arr[elf[1]-min_x+1, elf[2]-min_y+1] = '#'
    end
    return elf_arr
end

function score_elves(elves::Vector{Vector{Int16}})
    elf_array = generate_elf_array(elves)
    return count(i -> i == '.', elf_array)
end

function print_elves(elves::Vector{Vector{Int16}})
    elf_plot = generate_elf_array(elves)
    for n in 1:size(elf_plot)[1]
        for m in 1:size(elf_plot)[2]
            print(elf_plot[n, m])
        end
        print("\n")
    end
end


struct Movement
    old_pos::Vector{Int16}
    new_pos::Vector{Int16}
end
Base.:(==)(a::Movement, b::Movement) = a.new_pos==b.new_pos  # Match by new pos only

function Base.unique(x::Vector{Movement})
    output = []
    for mov in x
        if length(findall(val -> val==mov, x)) == 1
            push!(output, mov)
        end
    end
    return output
end

function find_neighbouring_dirs(dir::Vector{Int16})
    null_dir = findfirst(coord -> coord == 0, dir)
    dirs = Vector{Vector{Int16}}()
    for val in -1:1
        push!(dirs, setindex!(copy(dir), val, null_dir))
    end
    return dirs
end

function check_neighbours(elf::Vector{Int16}, elves::Vector{Vector{Int16}}, neighbours::Vector{Vector{Int16}})
    # Separate func to allow for compiler optimisation - this is the most expensive line
    return all(map(neighbour -> (neighbour .+ elf) ∉ elves, neighbours))
end

function proposed_step(elf::Vector{Int16}, elves::Vector{Vector{Int16}}, t::Int)
    dirs::Vector{Vector{Int16}} = [[-1, 0], [1, 0], [0, -1], [0, 1]]  # N/S/W/Each - in y,x format

    all_neighbours = unique(collect(Iterators.flatten([find_neighbouring_dirs(dir) for dir in dirs])))
    if check_neighbours(elf, elves, all_neighbours)
        return [0, 0]  # No neighbours - no need to move
    end  

    for i in t:t+4  # Consider all compass directions, rotating order
        dir = dirs[mod(i, 1:4)]
        dir_neighbours = find_neighbouring_dirs(dir)
        if check_neighbours(elf, elves, dir_neighbours)
            return dir
        end
    end
    return [0, 0]  # No available positions, so elf is stationary
end


function move_elves(elves::Vector{Vector{Int16}}, t::Int)
    # Create list of proposed movements
    proposal = Vector{Movement}()
    for elf in elves
        step = proposed_step(elf, elves, t)
        if step != [0, 0]
            push!(proposal, Movement(elf, elf + step))
        end
    end
    movements = unique(proposal)
    if length(movements) == 0  # Reached steady state
        return Vector(Vector([0]))  
    end

    # Complete movements that go to unique positions
    for movement in movements
        elf_ind = findfirst(pos -> pos==movement.old_pos, elves)
        elves[elf_ind] = movement.new_pos
    end
    return elves
end

function simulate_elves(elves::Vector{Vector{Int16}}, t_end::Int, verbose::Int=0)
    @profile for t in ProgressBar(1:t_end)
        elves = move_elves(elves, t)
        if elves == Vector(Vector([0]))  # End condition, conserving type of elves
            println("Reached steady state at t = $t, before final time $t_end reached.")
            break
        elseif verbose > 0
            print_elves(elves)
            println(repeat('-', 40))
        end
    end
    return elves
end


open("Week_4/Inputs/day_23.txt", "r") do f
    global lines = readlines(f)
end

elves::Vector{Vector{Int16}} = read_elves(lines)
simulate_elves(elves, 10)
println("Elf score after 10 rounds is $(score_elves(elves))")

simulate_elves(read_elves(lines), 10000); Profile.print()
