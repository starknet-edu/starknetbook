import time

hours = 0
carries = 0
modulus = 12

print()
####################
# Numbers "wrap"
# the modulus
####################
for i in range(720):
    print("\t Time: {:02d}\tHours: {:02d}\t Days: {:.1f}".format(hours % modulus, hours, carries/2), end = "\r")
    hours += 1
    if hours % modulus == 0:
        carries += 1
    time.sleep(0.3)