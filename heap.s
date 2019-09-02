    .data

NEGATED3 = 0xfffffffc
NODE_SIZE = 8 # size in bytes of an {int,addr}

newline: .asciiz "\n"
.align 2
node_buffer: .space 8

heap_array: .space 64   # array (will change to array pointer)
heap_size: .word 0      # amount of elements in heap
heap_capacity: .word 8  # maximum amount of elements

    .text
# $a0 - number to round
###########################
roundToWord:              #
  add $v0, $a0, 3         #
  and $v0, $v0, NEGATED3  #
  jr $ra                  #
###########################
# $v0 - rounded number

# $a0 - number of bytes
# $a1 - pointer to first element
# $a2 - pointer to second element
#############################
swap:                       #
  sub $sp, $sp, 12          #
  sw $s1, ($sp)             #
  sw $s2, 4($sp)            #
  sw $ra, 8($sp)            #
  move $s1, $a1             #
  move $s2, $a2             #
  sub $sp, $sp, $a0         #
                            #
  move $a1, $sp             #
  move $a2, $s1             #
  jal copy                  # T aux = first;
  move $a1, $s1             #
  move $a2, $s2             #
  jal copy                  # first = second;
  move $a1, $s2             #
  move $a2, $sp             #
  jal copy                  # second = aux;
                            #
  add $sp, $sp, $a0         #
  move $a1, $s1             #
  move $a2, $s2             #
  lw $s1, ($sp)             #
  lw $s2, 4($sp)            #
  lw $ra, 8($sp)            #
  add $sp, $sp, 12          #
  jr $ra                    #
#############################

# $a0 - amount of bytes of element to copy
# $a1 - pointer to writeable memory
# $a2 - pointer to readable memory
#############################
copy:                       #
  sub $sp, $sp, 8           #
  sw $a1, 0($sp)            #
  sw $a2, 4($sp)            #
                            #
  li $t0, 0                 # int i = 0
  copy_loop:                #
    beq $t0, $a0, copy_end  # while( i < sizeof(element) ) {
    lb $t4, ($a2)           #
    sb $t4, ($a1)           #   *(write) = *(read);
    add $a1, $a1, 1         #   write++;
    add $a2, $a2, 1         #   read++;
    add $t0, $t0, 1         #   i++;
    j copy_loop             #
  copy_end:                 # }
                            #
  lw $a1, 0($sp)            #
  lw $a2, 4($sp)            #
  add $sp, $sp, 8           #
  jr $ra                    #
#############################

# $a0 - pointer of element to insert
###################################
heap_insert:                      #
  sub $sp, $sp, 12                #
  sw $ra, ($sp)                   #
  sw $a0, 4($sp)                  #
  sw $s0, 8($sp)                  #
                                  #
  lw $t0, heap_size($0)           #
  lw $t1, heap_capacity($0)       #
                                  #
  bne $t0, $t1, hasroom           # if (heap_size == heap_capacity) {
    j exit                        #   exit(1);
  hasroom:                        # }
                                  #
  move $s0, $t0                   # int i = heap_size;
  la $a1, heap_array              #
  mul $t1, $s0, NODE_SIZE         #
  add $a1, $a1, $t1               # 
  move $a2, $a0                   #
  li $a0, NODE_SIZE               #
  jal copy                        # heap[i] = argument0
  add $t0, $s0, 1                 #
  sw $t0, heap_size($0)           # heap_size++;
                                  #
  mul $s0, $s0, NODE_SIZE         # // convert size to bytes  
  heap_insert_loop:               #
    beq $s0, $0, heap_insert_end  # while (i != 0 &&
    move $a0, $s0                 #
    jal heap_parent               # // parent(i)
    lw $t1, heap_array($s0)       # // heap[i].priority
    lw $t0, heap_array($v0)       # // heap[parent(i)].priority
    bge $t1, $t0, heap_insert_end # heap[parent(i)] > heap[i]) {
    li $a0, NODE_SIZE             #
    la $t0, heap_array            #
    add $a1, $t0, $v0             #
    add $a2, $t0, $s0             #
    jal swap                      # swap(&heap[i], &heap[parent(i)]);
    move $s0, $v0                 # i = parent(i);
    j heap_insert_loop            #
  heap_insert_end:                #
                                  #
  lw $ra, ($sp)                   #
  lw $a0, 4($sp)                  #
  lw $s0, 8($sp)                  #
  add $sp, $sp, 12                #
  j $ra                           #
###################################

# $a0 - index in bytes
###########################
heap_parent:              #
  div $v0, $a0, NODE_SIZE #
  sub $v0, $v0, 1         #
  div $v0, $v0, 2         #
  mul $v0, $v0, NODE_SIZE # return ((i-1) / 2);
  jr $ra                  #
###########################
# $v0 - parent index in bytes

# $a0 - index in bytes
###########################
heap_left:                #
  mul $v0, $a0, 2         #
  add $v0, $v0, NODE_SIZE # return (i*2 + 1);
  jr $ra                  #
###########################
# $v0 - left child index in bytes

# $a0 - index in bytes
###########################
heap_right:               #
  mul $v0, $a0, 2         #
  add $v0, $v0, NODE_SIZE #
  add $v0, $v0, NODE_SIZE # return (i*2 + 2);
  jr $ra                  #
###########################
# $v0 - right child index in bytes

###################################
heap_print:                       #
  sub $sp, $sp, 4                 #
  sw $a0, ($sp)                   #
  li $t0, 0                       # int i = 0;
  lw $t1, heap_size($0)           #
  mul $t1, $t1, NODE_SIZE         #
  li $v0, 1                       #
  heap_print_loop:                #
    beq $t0, $t1, heap_print_end  # while(i < heap_size) {
    lw $a0, heap_array($t0)       #
    syscall                       #   cout << heap[i].pty << heap[i].ptr;
    add $t0, $t0, 4               #
    j heap_print_loop             #   i++;
  heap_print_end:                 # }
  li $v0, 4                       #
  la $a0, newline                 #
  syscall                         # cout << endl;
  lw $a0, ($sp)                   #
  add $sp, $sp, 4                 #
  jr $ra                          #
###################################

main:
  li $s4, 4
  la $a0, node_buffer

loop:
  li $v0, 5
  syscall
  sw $v0, node_buffer($0)
  
  li $v0, 5
  syscall
  sw $v0, node_buffer($s4)

  jal heap_insert
  jal heap_print
  j loop
exit:
  li $v0, 10
  syscall