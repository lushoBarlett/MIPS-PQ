    .data

NEGATED3 = 0xfffffffc
NODE_SIZE = 16 # size in bytes of a Node {value,linkedlist,left,right}
VALUE_OFFSET = 0
LINKEDLIST_OFFSET = 4
LEFT_OFFSET = 8
RIGHT_OFFSET = 12

INPUT_SIZE = 8 # size in bytes of an Input Buffer {priority,string}
PRIORITY_OFFSET = 0
STRING_OFFSET = 4

newline: .asciiz "\n"
.align 2
int_buffer: .space 4
tree_pointer: .word 0

    .text
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

# $a0 current node's address
# $a1 data to insert
#######################################
bst_insert:                           #
  sub $sp, $sp, 8                     #
  sw $ra, 0($sp)                      #
  sw $a0, 4($sp)                      #
                                      #
  bne $a0, $zero notleaf              # if (node == nullptr) {
    # leaf                            #
    li $v0, 9                         #
    li $a0, NODE_SIZE                 #
    syscall                           #   child = new Node();
    lw $t1, PRIORITY_OFFSET($a1)      #   
    sw $t1, VALUE_OFFSET($v0)         #   child.value = data.priority;
    # call insert on this             #
    sw $zero, LINKEDLIST_OFFSET($v0)  #   child.linkedlist = linkedlist.push(&child, data.string);
    sw $zero, LEFT_OFFSET($v0)        #   child.left = nullptr;
    sw $zero, RIGHT_OFFSET($v0)       #   child.right = nullptr;
    j bst_insert_return               #   return child;
  notleaf:                            # }
                                      #
  lw $t0, VALUE_OFFSET($a0)           #
  lw $t1, PRIORITY_OFFSET($a1)        #
  bne $t0, $t1 notequal               # if (node.value == data.priority) {
    # call linked list insert         #   linkedlist.push(&node, data.string);
    lw $v0, 4($sp)                    #
    j bst_insert_return               #   return node;
  notequal:                           # }
                                      #
  bgt $t0, $t1 greater                # if (node.value < data.priority) { 
    # go left                         #   
    lw $a0, LEFT_OFFSET($a0)          #
    jal bst_insert                    #
    lw $a0, 4($sp)                    #
    sw $v0, LEFT_OFFSET($a0)          #   node.left = bst_insert(node.left,&data);
    move $v0, $a0                     #
    j bst_insert_return               #   return node;
  greater:                            # }
                                      #
  # go right                          #
  lw $a0, RIGHT_OFFSET($a0)           #
  jal bst_insert                      #
  lw $a0, 4($sp)                      #
  sw $v0, RIGHT_OFFSET($a0)           # node.right = bst_insert(node.right,&data);
  move $v0, $a0                       #
                                      #
  bst_insert_return:                  #
  lw $ra, 0($sp)                      #
  lw $a0, 4($sp)                      #
  add $sp, $sp, 8                     #
  jr $ra                              # return node;
#######################################
# $v0 address of bst

# $a0 current node's address
#################################
bst_delete:                     #  
  sub $sp, $sp, 8               #
  sw $ra, 0($sp)                #
  sw $a0, 4($sp)                #
                                #
  lw $t0, LEFT_OFFSET($a0)      #
  bne $t0, $zero cangoleft      # if (node.left == nullptr) {
    # call linkedlist delete    #
    # if return null            #   if (node.linkedlist = linkedlist.pop()) {
    # return node.right         #     return node;
    # else node                 #   }
    lw $v0, RIGHT_OFFSET($a0)   #
    j bst_delete_return         #   return node.right;
  cangoleft:                    # }
                                #
  # go left                     #   
  lw $a0, LEFT_OFFSET($a0)      #
  jal bst_delete                #
  lw $a0, 4($sp)                #
  sw $v0, LEFT_OFFSET($a0)      # node.left = bst_delete(node.left,&data);
  move $v0, $a0                 #
  j bst_delete_return           # return node;
                                #
  bst_delete_return:            #
  lw $ra, 0($sp)                #
  lw $a0, 4($sp)                #
  add $sp, $sp, 8               #
  jr $ra                        #
#################################
# $v0 address of bst, null if empty

main:
  li $s4, 4
  la $a0, int_buffer

loop:
  li $v0, 5
  syscall
  beq $v0, $0, loop2
  sw $v0, int_buffer($0)
  j loop
  
loop2:
exit:
  li $v0, 10
  syscall
