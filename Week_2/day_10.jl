function check_recorder(cycle::Int, recording_cycles::Vector{Int}, signals::Vector{Int}, val::Int)
    if cycle in recording_cycles
        push!(signals, val * cycle)
    end
end

function increment_cycle_index(cycle_index::Int, X::Int, curr_output::Vector{Char})
    # Increment cycle index. As side effect, also add next char to output stream
    if (abs((cycle_index % 40) - X) <= 1) push!(curr_output, '#') else push!(curr_output, '.') end
    cycle_index += 1
end

function print_output(final_output::Vector{Char})
    for n in 0:5  # Each line
        for m in 1:40
            print(final_output[40*n + m])
        end
        print("\n")
    end
end

open("Week_2/Inputs/day_10.txt", "r") do f
    indices_to_record = Vector(20:40:220) 
    signal_strengths = Vector{Int}()
    curr_output = Vector{Char}()

    X = 1; cycle_index = 0  # Register value and number of cycles completed

    while ! eof(f)
        command = split(readline(f), ' ')  # Gives command type and (optionally) value

        if command[1] == "addx"
            # Iterate cycle index in stages to check whether you hit target index mid operation
            for i in 1:2
                cycle_index = increment_cycle_index(cycle_index, X, curr_output)
                check_recorder(cycle_index, indices_to_record, signal_strengths, X)
            end
            X += parse(Int64, command[2])

        elseif command[1] == "noop"
            cycle_index = increment_cycle_index(cycle_index, X, curr_output)
            check_recorder(cycle_index, indices_to_record, signal_strengths, X)
        else
            @warn("Unrecognised command $(command[1]) - skipping")
        end
    end
    println("Number of cycles: $cycle_index")
    println("Summed signal strength at checkpoints: $(sum(signal_strengths))")
    print_output(curr_output)
end