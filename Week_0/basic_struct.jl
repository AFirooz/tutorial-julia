struct Human
    age::Int
    weight::Float64
    bio::String
end

function Human()
    # Make an empty human
    return Human(0, 0, "")
end

bob = Human(32, 72.5, "A builder")
println(bob.bio)