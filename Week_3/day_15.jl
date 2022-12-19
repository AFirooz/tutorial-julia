using ProgressBars

function manhattan_dist(pos_1::Vector{Int}, pos_2::Vector{Int})
    abs(pos_2[1] - pos_1[1]) + abs(pos_2[2] - pos_1[2])
end

function poss_beacon(x, y, input; inc_new_beacons=true)
    # If you put a beacon at (x, y), would is be closer than the current beacon to any sensor?
    # If so, then its not a valid position for a 'hidden' beacon
    for sensor in input
        if [x, y] == sensor[3:4]  # Beacon already exists here
            return if (inc_new_beacons) true else false end
        elseif manhattan_dist([x, y], sensor[1:2]) <= sensor[5]
            return false
        end
    end
    return true
end

row_vals = Vector{}()
min_x = Inf; max_x = -Inf  # Record extreme positions

open("Week_3/Inputs/day_15.txt", "r") do f
    while ! eof(f)
        measurement = [parse(Int64,match.match) for match in eachmatch(r"-?\d+", readline(f))]
        push!(measurement, manhattan_dist(measurement[3:4], measurement[1:2]))  # saves recalculation
        push!(row_vals, measurement)
        global min_x = min(min_x, measurement[1], measurement[3])
        global max_x = max(max_x, measurement[1], measurement[3])
    end
end

println("Extreme locations: $((min_x, max_x))")

row_target = 2000000
row_beacon_vacancies = 0  # For part A
for x in ProgressBar(-max_x:2*max_x)  # Really wide bounds bc I'm not smart enough to do better
    if !poss_beacon(Int(x), row_target, row_vals)
        global row_beacon_vacancies += 1
    end
end
println("In line $row_target there are $row_beacon_vacancies positions with no possible beacon")

coord_min = 0; coord_max = 4000000
total_beacon_vacancies = 0
for y in ProgressBar(coord_min:coord_max)
    for x in coord_min:coord_max
        if poss_beacon(Int(x), y, row_vals, inc_new_beacons = false)
            println("Valid beacon position at $((x, y))")
            println("This has a tuning frequency of $(4000000*x + y)")
        end
    end
end

