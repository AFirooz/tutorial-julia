# One day I will get through one of these problems without a BoundsError for indexing from zero

function calc_vis_peaks(A::Array)
    # It would be nicer to search from one viewpoint and the rotate the matrix
    # But frankly I didn't want to transform the visible peak locations so I can avoid doublecounting later

    visible_peaks = []

    # Vertical viewpoints
    for (i, col) in enumerate(eachcol(A))
        largest_peak_N = -1
        for (j, val) in enumerate(col)
            if val > largest_peak_N
                push!(visible_peaks, (i, j))
                largest_peak_N = val
            end
        end
        largest_peak_S = -1
        for (j, val) in Iterators.reverse(enumerate(col))
            if val > largest_peak_S
                push!(visible_peaks, (i, j))
                largest_peak_S = val
            end
        end
    end

    # Horizontal viewpoints
    for (j, row) in enumerate(eachrow(A))
        largest_peak_E = -1
        for (i, val) in enumerate(row)
            if val > largest_peak_E
                push!(visible_peaks, (i, j))
                largest_peak_E = val
            end
        end
        largest_peak_W = -1
        for (i, val) in Iterators.reverse(enumerate(row))
            if val > largest_peak_W
                push!(visible_peaks, (i, j))
                largest_peak_W = val
            end
        end
    end
    return visible_peaks
end

function direction_score(V::Vector)
    val = V[1]
    score = 0
    if length(V) == 1  # Tree on boundary of region
        return 0
    end
    for comp_val in V[2:end]
        score += 1
        if comp_val >= val
            break
        end
    end
    return score
end

function calc_scenic_scores(A::Array)
    # Okay I didn't want to do it this way but AoC Gods clearly do...
    scores = similar(A, Int64)
    for (i, col) in enumerate(eachcol(A))
        for j in eachindex(col)
            views = [  # N, E, S, W
                reverse(A[i, 1:j]), reverse(A[1:i, j]), A[i, j:end], A[i:end, j]
            ]
            direction_scores = [direction_score(view) for view in views]
            scores[i, j] = prod(direction_scores)
        end
    end
    return scores
end

open("Week_2/Inputs/day_8.txt", "r") do f

    # Read tree heights into a matrix (if only they had some kind of delimiter)
    lines = readlines(f)
    trees = zeros(Int8, length(lines[1]), length(lines))
    for (i, line) in enumerate(lines)
        for (j, num) in enumerate(line)
            trees[i, j] = parse(Int8, num)
        end
    end

    vis_trees = unique(calc_vis_peaks(trees))
    scenic_scores = calc_scenic_scores(trees)

    println("Number of visible trees: $(length(vis_trees))")
    println("Maximal scenic score: $(maximum(scenic_scores))")
end