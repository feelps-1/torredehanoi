def hanoi(numDisks, startingStack, auxStack, goalStack):
    if numDisks == 1:
        print(f"Mover o disco de {startingStack} para {goalStack}")
        return

    hanoi(numDisks-1, startingStack, goalStack, auxStack)
    print(f"Mover o disco de {startingStack} para {goalStack}")
    hanoi(numDisks-1, auxStack, startingStack, goalStack)

hanoi(3, 'A', 'B', 'C')
