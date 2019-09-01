# MIPS-PQ
Priority queue in MIPS processor

Each person will be assigned simple functions to implement using these [Rules](#Rules).
Details on input and output are specified [here](/specs.md).

## Rules

* follow [these rules](http://cs.brown.edu/courses/cs031/content/docs/asmguide.pdf).

Do:
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
