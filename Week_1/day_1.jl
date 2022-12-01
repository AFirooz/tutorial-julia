using Printf

open("Week_1/Inputs/day_1.txt", "r") do f
    current_elf = []
    elf_totals = []
    while ! eof(f)
        s = readline(f)
        if s == ""
            push!(elf_totals, sum(current_elf))
            current_elf = []
        else
            push!(current_elf, parse(Int, s))
        end
    end
    @printf("Largest subset total: %s \n", maximum(elf_totals))
    elf_totals = sort(elf_totals)
    @printf("Sum of three largest totals: %s \n", sum(elf_totals[end-2:end]))
end