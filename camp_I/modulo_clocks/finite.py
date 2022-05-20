
# Can represent a bit pattern with a polynomial
# 111 can be represented by
# x^2 + x + 1
# 101 can be represented by 
# x^2 + 1

# Polynomial Addition over a finite field
# (14x6) + (3x6 + 21x9)
# ---> 17x6 + 21x9
# if result is larger then p mod p and keep the remainder

# Polynomial Subtraction over a finite field


# Polynomial Muliplication over a finite field
# (1 + 2x2 + 3x5)*(x+7x4) 
# ---> 1*(x+7x4) + 2x2*(x+7x4) + 3x5*(x+7x4)
# ---> x + 7x4 + 2x3 + 14x6 + 3x6 + 21x9 
# ---> x + 2x3 + 7x4 + 17x6 + 21x9
# ---> divide by p(must be prime) and the remainder is the result of the multiplication
# if p is irreucible we have our feild as it can't be factored

# Polynomial Muliplication over a finite field
# (8x^2 + 3x + 3) / (2x + 1)
#        _______________ 
# 2x + 1 | 8x^2 + 3x + 2
#          8x^2 / 2x = 4x
#          (2x + 1) * 4x = 8x^2 + 4x
#          (8x^2 + 3x + 2) - (8x^2 + 4x)
#          (-x + 2)
#          (8x^2 + 3x + 2) / (-x + 2)

# our clock is a finite field 
hours = 13

print("DAYS: ", )