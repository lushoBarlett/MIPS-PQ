    .data

NEGATED3 = 0xfffffffc
NODE_SIZE = 16 # size in bytes of a Node {value,linkedlist,left,right}
VALUE_OFFSET = 0
LINKEDLIST_OFFSET = 4
LEFT_OFFSET = 8
RIGHT_OFFSET = 12

LINKED_LIST_NODE_SIZE = 8 # Tamaño del nodo de lista enlazada
OFFSET_DIRECCION = 0			# Direccion del siguiente elemento en la lista.
OFFSET_DATO	= 4					# Direccion del puntero al string.
STRING_MAX = 2					# Máxima cantidad de caracteres para los strings entrados con la funcion string.

INPUT_SIZE = 8 # size in bytes of an Input Buffer {priority,string}
PRIORITY_OFFSET = 0
STRING_OFFSET = 4

newline: .asciiz "\n"
.align 2
int_buffer: .space 4
tree_pointer: .word 0

    .text

# Pide un string por consola.
# No toma inputs.
#########################################
string:									                #
  sub $sp, $sp, 8                       #
  sw $a0, 0($sp)                        #
  sw $a1, 4($sp)                        #
                                        #
  li $a0, STRING_MAX					          #
  li $v0, 9								              #
  syscall								                #
										                    #
  move $a0, $v0 						            # 
  li $a1, STRING_MAX    				        #
  li $v0, 8								              #
  syscall								                # Pido el string.
										                    #
  move $v0, $a0     					          # Pongo en $v0 la direccion del string alojado.
  lw $a0, 0($sp)                        #
  lw $a1, 4($sp)						            #
  add $sp, $sp, 8                       #
  jr $ra								                #
#########################################
# $v0 - Direccion de alojamiento del string

# Pone un elemento al final de la lista. Recordar que este elemento es una direccion.
# $a0 - direccion de la lista. Es decir, direccion donde esta almacenada la direccion del primer elemento.
# $a1 - direccion del elemento a agregar.
#########################################
listaPush:								              #
  add $t0, $a0, 0						            #
  add $t1, $a1, 0						            # CAMBIAR A $SP
  lw $t2, ($a0)							            # $t2 - Direccion del primer elemento.
										                    #
  bne $t2, $0, ListaNoVacia				      # Si $t2 = 0 la lista esta vacia.
	  li $a0, LINKED_LIST_NODE_SIZE       #
    li $v0, 9							              #
    syscall								              # Alojo espacio para el nuevo elemento: 8 bytes.
    sw $v0, 0($t0)						          #
  	j listaPush_return					        #
  ListaNoVacia:                         #
                                        #
  listaPush_recorrer:					          # Primero tengo que llegar al ultimo elemento.
    add $t2, $t2, OFFSET_DIRECCION		  #
	  lw $t3, ($t2)						            # Veo la direccion del siguiente.
	  beq $t3, $0, listaPush_finRecorrer	# Si la direccion del siguiente es 0, estoy en el ultimo elemento.
										                    #
	  add $t2, $t3, 0 					          # Paso al siguiente elemento de la lista.
	  j listaPush_recorrer				        #
  listaPush_finRecorrer:       			    #
										                    #
  li $a0, LINKED_LIST_NODE_SIZE         #
  li $v0, 9								              #
  syscall								                # Alojo espacio para el nuevo elemento: 8 bytes.
										                    #
  sw $v0, OFFSET_DIRECCION($t2)			    #
										                    #
  listaPush_return:						          #
										                    #
  sw $0, OFFSET_DIRECCION($v0)			    # Como el nuevo elemento es el ultimo, la direccion del siguiente es 0.
  sw $t1, OFFSET_DATO($v0)				      # Guardo el contenido del nuevo elemento.
										                    #
  add $a0, $t0, 0						            #
  add $a1, $t1, 0						            #
  jr $ra								                #
#########################################

# Saca el primer elemento de la lista, y lo devuelve.
# $a0 - direccion de la lista. Es decir, direccion donde esta almacenada la direccion del primer elemento.
#########################################
listaPop:								                #
  lw $t1, ($a0)							            # $t1 - Direccion del primer elemento, el que voy a sacar.
  lw $t2, OFFSET_DIRECCION($t1)			    # $t2 - Direccion del segundo elemento, el que se volverá el primero.
										                    #
  sw $t2, OFFSET_DIRECCION($a0)			    # Almaceno la direccion del segundo elemento como el nuevo primero.
										                    #
  lw $v0, OFFSET_DATO($t1)				      # Preparo la direccion que voy a retornar.
  jr $ra								                #
#########################################
# $v0 - direccion del string popeado.

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
  sub $sp, $sp, 12                    #
  sw $ra, 0($sp)                      #
  sw $a0, 4($sp)                      #
  sw $a1, 8($sp)                      #
                                      #
  bne $a0, $zero notleaf              # if (node == nullptr) {
    # leaf                            #
    li $v0, 9                         #
    li $a0, NODE_SIZE                 #
    syscall                           #   child = new Node();
    lw $t1, PRIORITY_OFFSET($a1)      #   
    sw $t1, VALUE_OFFSET($v0)         #   child.value = data.priority;
    sw $zero, LINKEDLIST_OFFSET($v0)  #
    add $a0, $v0, LINKEDLIST_OFFSET   #
    add $a1, $a1, STRING_OFFSET       #
    jal listaPush                     #   linkedlist.push(&child.linkedlist, data.string);
    sw $zero, LEFT_OFFSET($v0)        #   child.left = nullptr;
    sw $zero, RIGHT_OFFSET($v0)       #   child.right = nullptr;
    j bst_insert_return               #   return child;
  notleaf:                            # }
                                      #
  lw $t0, VALUE_OFFSET($a0)           #
  lw $t1, PRIORITY_OFFSET($a1)        #
  bne $t0, $t1 notequal               # if (node.value == data.priority) {
    sw $zero, LINKEDLIST_OFFSET($a0)  #
    add $a0, $a0, LINKEDLIST_OFFSET   #
    add $a1, $a1, STRING_OFFSET       #
    jal listaPush                     #   linkedlist.push(&node.linkedlist, data.string);
    lw $v0, 4($sp)                    #
    j bst_insert_return               #   return node;
  notequal:                           # }
                                      #
  bgt $t0, $t1 greater                # if (node.value < data.priority) { 
    # go left                         #
    lw $a0, 4($sp)                    #   
    lw $a1, 8($sp)                    #   
    lw $a0, LEFT_OFFSET($a0)          #
    jal bst_insert                    #
    lw $a0, 4($sp)                    #
    sw $v0, LEFT_OFFSET($a0)          #   node.left = bst_insert(node.left,&data);
    move $v0, $a0                     #
    j bst_insert_return               #   return node;
  greater:                            # }
                                      #
  # go right                          #
  lw $a0, 4($sp)                      #   
  lw $a1, 8($sp)                      #   
  lw $a0, RIGHT_OFFSET($a0)           #
  jal bst_insert                      #
  lw $a0, 4($sp)                      #
  sw $v0, RIGHT_OFFSET($a0)           # node.right = bst_insert(node.right,&data);
  move $v0, $a0                       #
                                      #
  bst_insert_return:                  #
  lw $ra, 0($sp)                      #
  lw $a0, 4($sp)                      #
  lw $a1, 8($sp)                      #
  add $sp, $sp, 12                    #
  jr $ra                              # return node;
#######################################
# $v0 address of bst

# $a0 current node's address
#######################################
bst_delete:                           #  
  sub $sp, $sp, 8                     #
  sw $ra, 0($sp)                      #
  sw $a0, 4($sp)                      #
                                      #
  lw $t0, LEFT_OFFSET($a0)            #
  bne $t0, $zero cangoleft            # if (node.left == nullptr) {
    add $a0, $a0, LINKEDLIST_OFFSET   #
    jal listaPop                      #   linkedlist.pop(&node.linkedlist)
    bne $a0, $0, bst_delete_notempty  #   if (node.linkedlist == nullptr) {
      lw $v0, RIGHT_OFFSET($a0)       #
      j bst_delete_return             #     return node.right;
    bst_delete_notempty:              #   }
    lw $v0, 4($sp)                    #   
    j bst_delete_return               #   return node;
  cangoleft:                          # }
                                      #   
  lw $a0, LEFT_OFFSET($a0)            #
  jal bst_delete                      #
  lw $a0, 4($sp)                      #
  sw $v0, LEFT_OFFSET($a0)            # node.left = bst_delete(node.left,&data);
  move $v0, $a0                       #
  j bst_delete_return                 # return node;
                                      #
  bst_delete_return:                  #
  lw $ra, 0($sp)                      #
  lw $a0, 4($sp)                      #
  add $sp, $sp, 8                     #
  jr $ra                              #
#######################################
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
