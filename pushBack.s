#En .data tengo una variable "array" -> direccion dememoria que apunta al array
#El array tiene una Capacidad	-> Lo que puede contener
#								un Tamaño			-> Elementos que contiene
#
#Necesito hacer una funcion array_push_back dado un puntero a un elemento, poner una copia del elemento al final del array.
#Si no entra tengo que hacer duplicado de memoria (funcion duplicado): 1) Reservo el doble de memoria que lo que ocupa el array
#																																			2) Copio todo lo que ya hay al nuevo lugar
#																																			3) Ahora si pongo el elemento
#
#Tengo que llevar registro del tamaño y del puntero al array.
#
#Tips:
#	1) funcioncopy de lusho
#	2) el tamaño de un elemento ya esta en heap.s, se llama NODE_SIZE
#	3) tomar como referencia el codigo que ya existe

.data
NODE_SIZE = 8 # size in bytes of an {int,addr}
array: .space 4						# Pointer to array that contains elements of type {int,addr}
array_size: .word 0				# Amount of elements stored in array
array_capacity: .word 0		# Maximum amount of elements that fit inside the array

.text

# This function allocates space in memory for an array and updates array_capacity
# $a0 - Amount of spaces to allocate
#####################
allocate:
	la $t0, array_capacity
	lw $t1, 0($t0)
	addi $t2, $a0, 0

	mul $a0, $a0, NODE_SIZE
	li $v0, 9

	add $t1, $t1, $a0
	sw $t1, ($t0)

	addi $a0, $t2, 0
#####################
# $v0 - Allocated memory address
