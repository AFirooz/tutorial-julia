arr_1D = [1, 2, 3, 4]
arr_2D = [1 2; 3 4]
println(arr_2D[4])

matrix = zeros(Int8, 3, 3)
println(size(matrix))
println(ndims(matrix) == length(size(matrix)))
