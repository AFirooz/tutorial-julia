# I did consider an OOP approach with monkey classes, I really did...
# But they would still have to be accessed through a list as we only 
# care about their indices, so this felt just as natural.
# Ofc it would be even better if Julia indexed from zero...
passing_rounds::Int = 10000

# Change commenting of lines 57/58 for Parts A and B respectively
open("Week_2/Inputs/day_11.txt", "r") do f
    global monkey_lists = Vector{Vector{Int}}()
    global monkey_ops = Vector{}()
    global monkey_divisors = Vector{Int}()
    global monkey_receivers = Vector{Tuple{Int, Int}}()  # In form (True, False)

    # Read in input file, exploiting our knowledge of its exact form
    lines = readlines(f)
    monkey_index = 0
    for (i, line) in enumerate(lines)
        if startswith(line, "Monkey")
            # Read in starting items
            items = split(split(lines[i+1], ':')[end], ',')
            items = [parse(Int64, item) for item in items]
            push!(monkey_lists, items)

            # Read in function
            func_ops = split(lines[i+2], ' ')
            if func_ops[end-1] == "+"
                push!(monkey_ops, x -> x + parse(Int, func_ops[end]))
            elseif func_ops[end-1] == "*"
                if func_ops[end] == "old"
                    push!(monkey_ops, x -> x * x)
                else
                    push!(monkey_ops, x -> x * parse(Int, func_ops[end]))
                end
            else
                @warn("Unknown operator $(func_ops[end-1])")
            end

            # Read in monkey_divisors & receivers (+1 to compensate for indexing from 1)
            push!(monkey_divisors, parse(Int64, split(lines[i+3], ' ')[end]))
            receievers = (parse(Int64, split(lines[i+4], ' ')[end]) + 1,
                          parse(Int64, split(lines[i+5], ' ')[end]) + 1)
            push!(monkey_receivers, receievers)
            monkey_index += 1
        end
    end
    global monkey_num = monkey_index
end

monkey_inspection_count = zeros(Int64, monkey_num)
worry_modulo = prod(monkey_divisors)
for t in 1:passing_rounds
    for i in 1:monkey_num
        for item in deepcopy(monkey_lists[i])  
            # Deepcopy so you can modify list while iterating through original

            worry = monkey_ops[i](item)  # Update worry during inspection
            # worry = floor(worry / 3)  # Part A: Update worry post inspection
            worry = worry % worry_modulo  # Part B: This doesn't affect worry divisors
            popfirst!(monkey_lists[i])  # Throw item

            if worry % monkey_divisors[i] == 0
                new_monkey = monkey_receivers[i][1]
            else
                new_monkey = monkey_receivers[i][2]
            end
            push!(monkey_lists[new_monkey], worry)  # Catch item

            monkey_inspection_count[i] += 1
        end
    end
end

sorted_counts = sort(monkey_inspection_count)
monkey_business = sorted_counts[end] * sorted_counts[end-1]
println("Level of Monkey Business: $monkey_business")