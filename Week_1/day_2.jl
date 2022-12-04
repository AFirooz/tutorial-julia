you = ['X', 'Y', 'Z']
opp = ['A', 'B', 'C']

open("Week_1/Inputs/day_2.txt", "r") do f
    total_score_a = 0
    total_score_b = 0
    while ! eof(f)
        values = split(readline(f))

        # Play given move (part A)
        total_score_a += indexin(values[2], you)[1]  # Score from your move

        diff = indexin(values[2], you)[1] - indexin(values[1], opp)[1]
        total_score_a += 3 * ((diff + 4) % 3)  # Score from game outcome

        # Work out required move to achieve desired outcome (Part B)
        move_ind = (indexin(values[2], you)[1] - 2 + indexin(values[1], opp)[1]) % 3
        if move_ind == 0
            move_ind = 3  # Hack way to cope with indexing from one in Julia
        end
        total_score_b += move_ind  # Score from your move
        total_score_b += 3 * (indexin(values[2], you)[1] - 1)  # Score from game outcome
        
    end
    println("Total score (given moves): $total_score_a")
    println("Total score (given outcomes): $total_score_b")
end