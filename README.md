# MIPS-PQ
Priority queue in MIPS processor

Each person will be assigned simple functions to implement using these [Rules](#Rules).
Details on input and output are specified [here](/specs.md).

## Rules

* Functions will manipulate values in memory, meaning no arguments will be passed or returned in registers (unless for a specific and useful purpose).
* Tags have to be on the left of the first line of code, and all code until the end of that section has to be aligned.

Do:
```Assembly
f: li $t0, 0
   andi $t0, 0x1
Loop: addi $t0, 1
      move $a0, $t0
      beq $a0, $t0, End
      j Loop
End: move $a1, $a0
     jr
```

Don't:
```Assembly
f: 
li $t0, 0
andi $t0, 0x1
Loop: 
addi $t0, 1
move $a0, $t0
beq $a0, $t0, End
j Loop
End: 
move $a1, $a0
jr
```

* Do your damn job.

## Have fun!

Most important of all, this is just an assignement and not an actual paid job so don't go bonkers, but do finish in time please.
