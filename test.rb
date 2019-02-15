puts "Hello there! Please enter a number to square: "
number = gets.chomp.to_i

def square(number)
    squared = number * number
    return squared.to_s
end

puts "Your number is: " + number.to_s
puts "Your number squared is: " + square(number)
