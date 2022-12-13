import JSON

function compare_packets(p1, p2)
    local index = 1
    while index < 10
        try
            global v1, v2 = p1[index], p2[index]
        catch e
            if e isa BoundsError
                if length(p1) == length(p2)
                    return nothing  # Occurs in recursion unless input identical
                end
                return if (length(p1) < length(p2)) true else false end
            else
                rethrow(e)
            end
        end
        if isa(v1, Int) && isa(v2, Int)
            if v1 > v2
                return false
            elseif v1 < v2
                return true
            else
                index += 1
                continue
            end
        elseif isa(v1, Vector) && isa(v2, Vector)
            output = compare_packets(v1, v2)
            if !isnothing(output)
                return output
            else
                index += 1
                continue
            end
        else
            if isa(v1, Vector) && isa(v2, Int)
                output = compare_packets(v1, Vector([v2]))
            elseif isa(v1, Int) && isa(v2, Vector)
                output = compare_packets(Vector([v1]), v2)
            else
                @warn("Unknown comparison types $((typeof(v1), typeof(v2)))")
            end

            if !isnothing(output)
                return output
            else
                index += 1
                continue
            end
        end
    end
end

open("Week_2/Inputs/day_13.txt", "r") do f
    pair_strs = split(read(f, String), "\r\n\r\n")
    ordered_pair_inds = Vector{Int}()
    all_packets = Vector()
    for (pair_ind, pair_str) in enumerate(pair_strs)
        packet_strs = split(pair_str, "\r\n")
        packets = Vector()
        for packet_str in packet_strs
            push!(packets, JSON.parse(packet_str))   
            push!(all_packets, JSON.parse(packet_str))           
        end
        if compare_packets(packets...)
            push!(ordered_pair_inds, pair_ind)
        end
    end
    println("Summed indices of correctly ordered pairs: $(sum(ordered_pair_inds))")

    # Part B
    push!(all_packets, Vector(Vector([2]))); push!(all_packets, Vector(Vector([6])))
    sort!(all_packets, lt = compare_packets)  # Use built in sorting based on custom comparison
    divider_indices = [findfirst(x->x==Vector(Vector([n])), all_packets) for n in [2, 6]]
    println("Product of divider indices: $(prod(divider_indices))")
end
