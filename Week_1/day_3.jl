function priority(x::Char)
    # Converts char to priority usin ASCII values
    if islowercase(x)
        return Int(x) - 96
    else  # Uppercase
        return (Int(x) - 64) + 26
    end
end

open("Week_1/Inputs/day_3.txt", "r") do f
    duplicates_sum = 0
    shared_sum = 0

    lines = readlines(f)  # Need all lines at once for Part b
    for (index, line) in enumerate(lines)
    
        # Part A - Find duplicate item in each backpack
        sections = [line[1:Int(length(line)/2)], line[(Int(length(line)/2) + 1):end]]
        duplicate_item = intersect(sections[1], sections[2])[1]
        duplicates_sum += priority(duplicate_item)

        # Part B - Find shared item across each elf trio
        if index % 3 == 0  # End of group
            shared_item = intersect(line, lines[index - 1], lines[index - 2])[1]
            shared_sum += priority(shared_item)
        end
    end
    println("Summed priority of duplicate items: $duplicates_sum")
    println("Summed priority of shared items: $shared_sum")
end