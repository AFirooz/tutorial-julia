open("Week_1/Inputs/day_6.txt", "r") do f
    line = readlines(f)[1]  # Data package is all on one line
    global packet_index = 4  # Earliest possible value
    global message_index = 14

    global found_packet = false
    global found_message = false

    # Find all sets of indices that match, and keep any sets with more that 1 match (for self)
    find_repeats(a) = filter(x -> length(x) > 1, [findall(x -> x == a[i], a) for i in eachindex(a)])
    while true
        packet = line[packet_index-3:packet_index]
        message = line[message_index-13:message_index]
        if (!found_packet && isempty(find_repeats(packet)))
            println("Index of end of packet: $packet_index")
            found_packet = true
        end
        if (!found_message && isempty(find_repeats(message)))
            println("Index of end of message: $message_index")
            found_message = true
        end
        if found_message && found_packet
            break
        end
        packet_index += 1
        message_index += 1
    end
end