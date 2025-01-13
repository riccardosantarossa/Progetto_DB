

file = open('numeriTelefono.txt', 'r')
y = {0,}
for x in file:
    if x not in y:
        y.add(x)

print(len(y))