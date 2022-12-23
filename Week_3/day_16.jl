using DataStructures, SimplePartitions, ProgressBars, Profile

struct Valve
    name::String
    flow::Int
    connections::Vector{String}
    visited::Bool
end

function floyd_warshall_dist(rooms:: OrderedDict{String, Valve})
    dist = fill(Inf, (length(rooms), length(rooms)))
    for (i, room) in enumerate(keys(rooms))
        dist[i, i] = 0  # For each vertex
        for connection in rooms[room].connections
            destination_index = findfirst(x -> x == connection, collect(keys(rooms)))
            dist[i, destination_index] = 1  # For each edge
        end
    end
    for k in 1:length(rooms)
        for i in 1:length(rooms)
            for j in 1:length(rooms)
                if dist[i,j] > (dist[i,k] + dist[k,j])
                    dist[i,j] = dist[i,k] + dist[k,j]
                end
            end
        end
    end
    return dist
end

function release_pressure(valves, distances, valves_to_open, start_location, time_limit)
    maximum_pressure = 0
    
    # Stack of our current branches - [path], minutes_elapsed, {valve: minute opened}
    s = [[[start_location], 0, Dict()]]
    @profile while length(s) > 0
        path, minutes_elapsed, open_valves = pop!(s)
        current_valve = path[end]
        
        # If we've opened all valves or ran out of time, calc pressure for this branch of network
        if ((minutes_elapsed >= time_limit) || (length(path) == length(valves_to_open) + 1))
            pressure_released = 0
            
            for (valve, minute_opened) in pairs(open_valves)
                minutes_opened = max(time_limit - minute_opened, 0)
                pressure_released += valves[valve].flow * minutes_opened
            end
            maximum_pressure = max(maximum_pressure, pressure_released)
            
        else
            for next_valve in valves_to_open
                if next_valve ∉ keys(open_valves)
                    travel_time = distances[findfirst(x->x==current_valve, collect(keys(valves))),
                    findfirst(x->x==next_valve, collect(keys(valves)))]
                    
                    time_to_open_valve = 1
                    new_minutes_elapsed = minutes_elapsed + travel_time + time_to_open_valve
                    
                    new_open_valves = copy(open_valves)
                    new_open_valves[next_valve] = new_minutes_elapsed
                    
                    new_path = copy(path)
                    push!(new_path, next_valve)
                    push!(s, [new_path, new_minutes_elapsed, new_open_valves])
                end
            end
        end
    end
    return maximum_pressure
end


valves = OrderedDict{String, Valve}()
open("Week_3/Inputs/day_16.txt", "r") do f
    lines = readlines(f)
    for line in lines
        name = line[7:8]
        flow = parse(Int, filter(isdigit, line))
        connections = split(line[9 + findfirst(isuppercase, line[10:end]):end], ", ")
        valves[name] = Valve(name, flow, connections, false)
    end
end

distances = floyd_warshall_dist(valves)

valves_to_open = map(valve -> valve.name, filter(room -> room.flow > 0, collect(values(valves))))
total_pressure = release_pressure(valves, distances, valves_to_open, "AA", 30)
Profile.print(); println("Total pressure released: $total_pressure")

n_searchers = 2; mult_searcher_pressure = 0
for valve_collections in ProgressBar(all_partitions(Set(valves_to_open), n_searchers))
    curr_pressure = 0
    for i in 1:n_searchers
        valve_subset = collect(collect(valve_collections)[i])
        curr_pressure += release_pressure(valves, distances, valve_subset, "AA", 26)
    end
    global mult_searcher_pressure = max(mult_searcher_pressure, curr_pressure)
end

println("Total pressure released (with helper): $mult_searcher_pressure")
