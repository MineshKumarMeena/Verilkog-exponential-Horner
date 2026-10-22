import math

scale = 65536

testinputs = [-1,-0.75,-0.5,-0.25,0,0.1,0.25,0.5,0.75,1]
print("Input x\tActual e^x\tFixed Point value")

for x in testinputs:
    output = math.exp(x)
    approx = round(output*scale)

    print(f"{x}\t{output:.6f}\t{approx}")
