function my_addition(x, y)
    return x + y
end

function my_addition(x::String, y::String)
    # Return statement is optional - otherwise defaults to last expression
    x * y  
end

println(my_addition(3, 5))  # Prints with a new line
println(my_addition("3", "5"))


Σ(a,b) = a + b
Σ_2 = (a, b) -> a + b  # Cannot override name for Σ
println(Σ(2.4, 4.5))
println(Σ_2(2.4, 4.5))

