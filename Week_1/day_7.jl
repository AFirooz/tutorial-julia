# Could have implemented a tree but didn't fully (nested dictionary instead)
# Proud of my parsing ad recursion here in a new language anyway!

using JSON

open("Week_1/Inputs/day_7.txt", "r") do f
    global file_dir = Dict("/" => Dict())
    global current_dir = ["/"]  # Stored as a list of keys for each directory
    global max_depth = 1
    while ! eof(f)
        line = readline(f)
        if startswith(line, "\$ cd")  # UPDATE CURRENT DIRECTORY
            new_dir = line[6:end]
            if new_dir == "/"
                current_dir = ["/"]
            elseif new_dir == ".."
                pop!(current_dir)
            else
                local_dir = file_dir
                for dir in current_dir
                    local_dir = local_dir[dir]
                end
                if !(new_dir in keys(local_dir))  # ADD NEW DIRECTORY
                    local_dir[new_dir] = Dict()
                end
                push!(current_dir, new_dir)
                max_depth = max(max_depth, length(current_dir))
            end

        elseif startswith(line, "\$ ls")  # LIST FILES IN CURRENT DIR
            global local_dir = file_dir
            for dir in current_dir
                local_dir = local_dir[dir]
            end
                  
        else  # ADD FILES TO CURRENT DIRECTORY
            line_vals = split(line)
            if line_vals[1] == "dir" 
                continue  # Directory added in cd 
            else
                local_dir[line_vals[2]] = line_vals[1]
            end
        end
    end
    println("Maximum folder depth: $max_depth")
    # print(json(file_dir, 2))  # Used to pretty-print file directory system
end


# FIND SIZES OF EACH DIRECTORY - RECURSIVE FUNCTION
function find_dict_sizes(dict, sizes)
    local dict_size = 0
    for (key, value) in dict
        if value isa Dict
            find_dict_sizes(value, sizes)
            try
                global dict[key] = string(sizes[end])
            catch 
                @warn("May be raised at top level if unable to convert dict to string sum. 
                       Not an issue if only raised once.")
                break
            end
        end
        value = dict[key]  # Update value incase it was changed by dict summation above
        if value isa AbstractString
            dict_size += parse(Int, value)
        else
            println((value, typeof(value)))
            @warn("Found dict entry $value of unrecognised type $(typeof(value))")
        end
    end
    push!(sizes, dict_size)
end

sizes_list = []
dir_sizes = find_dict_sizes(deepcopy(file_dir), sizes_list)

# FIND SUMMED  SIZE OF SMALL DIRECTORIES
small_dir_size_limit = 100_000
small_dirs = filter((x) -> x < small_dir_size_limit, dir_sizes) 

# FIND THE SMALLEST DIRECTORY THAT WILL GIVE ENOUGH ROOM
total_size = 70_000_000; req_space = 30_000_000

req_to_delete = req_space - (total_size - maximum(dir_sizes))
big_enough_dirs = sort(filter((x) -> x > req_to_delete, dir_sizes))

println("Summed size of all small directories: $(sum(small_dirs))")
println("Total size smallest directory that gives sufficient memory: $(big_enough_dirs[1])")
