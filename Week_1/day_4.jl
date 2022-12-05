open("Week_1/Inputs/day_4.txt", "r") do f
    num_complete_overlaps = 0
    num_partial_overlaps = 0
    while ! eof(f)
        range_strings = split(readline(f), ',')
        ranges = [split(range, '-') for range in range_strings]
        ranges = [[parse(Int64, x) for x in r] for r in ranges]
        
        # Complete overlap of ranges (Part A) - yes its not the most elegant (maybe?)
        if ((ranges[1][1] <= ranges[2][1]) && (ranges[1][2] >= ranges[2][2]))
            num_complete_overlaps += 1
        elseif ((ranges[1][1] >= ranges[2][1]) && (ranges[1][2] <= ranges[2][2]))
            num_complete_overlaps += 1
        end

        # Partial overlap of ranges (Part B)
        if ((ranges[1][2] >= ranges[2][1]) && (ranges[1][1] <= ranges[2][2]))
            num_partial_overlaps += 1
        elseif ((ranges[1][2] <= ranges[2][1]) && (ranges[1][1] >= ranges[2][2]))
            num_partial_overlaps += 1
        end
    end
    println("Number of ranges with complete overlap: $num_complete_overlaps")
    println("Number of ranges with partial overlap: $num_partial_overlaps")
end