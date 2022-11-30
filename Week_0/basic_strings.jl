using Printf

function find_type(x::T) where {T}
    println(T)
    return nothing  # Used for a function which only has side effects
end 

function check_char(x::T) where {T}
    @printf("'%s'", x)
    if T == Char
        println(" is Char")
    else
        println(" is not Char")
    end
end

find_type('c')

check_char('c')
check_char("string")
