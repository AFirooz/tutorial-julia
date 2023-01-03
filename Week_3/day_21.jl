function forwards_monkey_exclamation(monkeys, monkey_names = keys(monkeys))
    operator_map = Dict("+" => ((x, y) -> x + y), "-" => ((x, y) -> x - y),
                        "*" => ((x, y) -> x * y), "/" => ((x, y) -> x / y))
    while true
        shout_count = 0
        for name in monkey_names
            if monkeys[name] isa SubString
                instr = split(monkeys[name], " ")
                if (monkeys[instr[1]] isa Int64) && (monkeys[instr[3]] isa Int64)
                    monkeys[name] = Int64(operator_map[instr[2]](monkeys[instr[1]], monkeys[instr[3]]))
                    shout_count += 1
                end
            end
        end
        if shout_count == 0  # No more monkeys to change
            return monkeys["root"]
        end
    end
end

function human_exclamation(monkeys)
    monkey_names = filter(name -> name != "root" && name != "humn", keys(monkeys))
    monkeys["humn"] = SubString("mystery", 1:7)

    forwards_monkey_exclamation(monkeys, monkey_names)  # Evaluate as many monkeys as poss forwards

    # Find correct value for root comparison
    instr = split(monkeys["root"], " ")
    next_monkey = [val for val in instr if length(val) == 4][1]  # The undetermined source monkey for root
    monkeys["root"] = Int64([monkeys[val] for val in instr[[1;3]] if monkeys[val] isa Int64][1])  # Find val of determined source monkey

    # Create map for inverse operations based on forward operator and index of known value
    inv_operator_map = Dict(("+", 2) => ((ans, x2) -> ans-x2), ("+", 1) => ((ans, x1) -> ans-x1),
                            ("-", 2) => ((ans, x2) -> ans+x2), ("-", 1) => ((ans, x1) -> x1-ans),
                            ("*", 2) => ((ans, x2) -> ans/x2), ("*", 1) => ((ans, x1) -> ans/x1),
                            ("/", 2) => ((ans, x2) -> ans*x2), ("/", 1) => ((ans, x1) -> x1/ans),)

    # Work backwards through undetermined monkeys (from root to humn), inverting all operators
    # Each monkey has two "source monkeys", of which we know one value and want to obtain the other.
    next_value = monkeys["root"]
    while true
        curr_monkey = next_monkey
        curr_value = next_value
        instr = split(monkeys[next_monkey], " ")
        monkeys[curr_monkey] = curr_value  # Overwrite instr for curr_monkey with their value

        next_monkey = [name for name in instr if (length(name) == 4 && monkeys[name] isa SubString)][1]  # The undetermined source monkey for curr_monkey
        map_key = (instr[2], findfirst(name -> monkeys[name] isa Int64, instr[[1;3]]))  # Index in instr of known value
        next_value = Int64(inv_operator_map[map_key](curr_value, monkeys[instr[(2*map_key[2])-1]]))
        
        if next_monkey == "humn"
            return next_value
        end
    end
end


open("Week_3/Inputs/day_21.txt", "r") do f
    global monkeys = Dict{SubString, Union{SubString, Int64}}(
        (split(line, ": ")[1] => split(line, ": ")[2]) for line in readlines(f))
end

# Parse ints for number-shouting monkeys
for name in keys(monkeys)
    if !isnothing(tryparse(Int64, monkeys[name]))
        monkeys[name] = parse(Int64, monkeys[name])
    end
end

println("Root monkey shouted: $(forwards_monkey_exclamation(copy(monkeys)))")
println("The human should shout: $(human_exclamation(monkeys))")