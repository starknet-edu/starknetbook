####################
# Greatest Common
# Divisor:
# ax + by = 1
####################
def xgcd( x, y ):
    old_r, r = (x, y)
    old_s, s = (1, 0)
    old_t, t = (0, 1)
    count = 0
    while r != 0:
        print("\tfinding the xgcd({}): {} {} {}".format(count, old_r, old_t, old_s), end = "\r")
        count += 1
        quotient = old_r // r
        old_r, r = (r, old_r - quotient * r)
        old_s, s = (s, old_s - quotient * s)
        old_t, t = (t, old_t - quotient * t)

    print()
    return old_s, old_t, old_r # a, b, g

prime=13

print("Finite Field Math Operators:")
####################
# FF Addition
####################
lefthand=4
righthand=12
print("\tAddition: ({} + {}) % {} = {}\n".format(lefthand, righthand, prime, (lefthand + righthand) % prime))

####################
# FF Subtraction
####################
lefthand=35
righthand=5
print("\tSubtraction: ({} - {}) % {} = {}\n".format(lefthand, righthand, prime, (lefthand + righthand*-1) % prime))

####################
# FF Multiplication
####################
lefthand=90
righthand=10
print("\tMultiplication: ({} * {}) % {} = {}\n".format(lefthand, righthand, prime, (lefthand * righthand) % prime))

####################
# FF Division
####################
dividend = 2
divisor = 3
print("\tDivision: ({} / {})".format(dividend, divisor))
a, b, g = xgcd(divisor, prime)
print("\tfound: {}*{} + {}*{}=1".format(a, divisor, b, prime))
print("\t({} / {}) % {} = {}\n".format(dividend, divisor, prime, (dividend * a) % prime))
