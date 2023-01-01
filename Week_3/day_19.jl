function insufficient_geode_capacity(geode_bots, time_left, curr_geode, max_geode)
    # Calculate is maximal geode production on current branch could beat current max output
    # Maximal geode production assumes a geode robot is produced on every subsequent step
    branch_max = curr_geode + geode_bots * time_left + (time_left * (time_left - 1)) / 2
    return branch_max <= max_geode
end

function calc_available_robots(robots, costs)
    # If we can produce enough of a given resource to build any bot in one timestep,
    # we don't need any more of that bot. Also require that previous bot must already be built.
    
    available_bots = [1:min(findlast(bot_num -> bot_num >= 1, robots) + 1, 4)...]
    if robots[1] >= max([arr[1] for arr in costs]...)
        deleteat!(available_bots, 1)
    end
    if robots[2] >= costs[3][2]
        deleteat!(available_bots, findall(x->x==2,available_bots))
    end
    if robots[3] >= costs[4][3]
        deleteat!(available_bots, findall(x->x==3,available_bots))
    end
    return available_bots
end

function dfs_search(robots, ores, costs, time_left)
    current_max = 0
    states = Set()
    dfs_queue = Vector([Vector([time_left, ores, robots, nothing])])
    while length(dfs_queue) > 0
        time_left, ores, robots, next_bot = pop!(dfs_queue)
        if insufficient_geode_capacity(robots[end], time_left, ores[end], current_max)
            continue  # Prune branch if it can't catch up with optimal branch
        end
        if ! isnothing(next_bot)
            cost_for_next_bot = costs[next_bot]
            res_for_next_bot = cost_for_next_bot - ores
            possible_times = [if (c > 0 && d > 0) ceil(c / d) else 0 end for (c, d) in zip(res_for_next_bot, robots)]
            time_for_next_bot = Int(max(possible_times...)) + 1
            if time_left - time_for_next_bot <= 0
                ores += robots * time_left
                if ores[end] > 0
                    push!(states, [time_left, ores, robots])
                    current_max = max(current_max, ores[end])
                end
                continue
            end
            ores += time_for_next_bot * robots - cost_for_next_bot
            time_left -= time_for_next_bot
            robots[next_bot] += 1
        end
        if (time_left > 0 && (ores[end] + robots[end] * time_left + (time_left - 1) * (time_left) // 2) > current_max)
            available_bots = calc_available_robots(robots, costs)  # Prune tree to remove extraneous & unavailable bots

            for bot in available_bots
                push!(dfs_queue, [time_left, copy(ores), copy(robots), bot])
            end
        end
    end
    return Int(max([res[end] for (_, res, _ ) in states]..., 0))
end

function maximal_geode_production(costs, max_time)
    robots = Vector([1, 0, 0, 0])
    ores = Vector([0, 0, 0, 0])

    # DFS search considering adding each robot to production queue sequentially
    return dfs_search(robots, ores, costs, max_time)
end


open("Week_3/Inputs/day_19.txt", "r") do f
    summed_qf = 0
    geode_product = 1
    while ! eof(f)
        blueprint = [parse(Int64,match.match) for match in eachmatch(r"-?\d+", readline(f))]

        # Read in costs vector - Ore/Clay/Obsidian/Geode
        costs = Vector([
            [blueprint[2], 0, 0, 0],  # Cost for ore robot
            [blueprint[3], 0, 0, 0],  # Cost of clay robot
            [blueprint[4], blueprint[5], 0, 0],  # Cost of obsidian robot
            [blueprint[6], 0, blueprint[7], 0]  # Cost of geode robot
        ])
        geodes = maximal_geode_production(costs, 24)
        summed_qf += blueprint[1] * geodes

        if blueprint[1] <= 3  # Part B
            geode_product *= maximal_geode_production(costs, 32)
        end
    end
    println("Total Quality Factor of all Blueprints: $summed_qf")
    println("Product of Geodes from first 3 Blueprints: $geode_product")
end
