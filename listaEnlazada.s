# Implementación de lista enlazada.
# La lista almacena punteros a strings.
# Entonces cada elemento consta de un puntero a un char y un puntero al proximo elemento.
# Estos punteros son words, cada elemento ocupa 8 bytes (4 para el nodo* y 4 para el char*).
# En esta implementación, 0 representa null para las direcciones.

.data
OFFSET_DIRECCION = 0			# Direccion del siguiente elemento en la lista.
OFFSET_DATO	= 4					# Direccion del puntero al string.
STRING_MAX = 2					# Máxima cantidad de caracteres para los strings entrados con la funcion string.

#stringg: .asciiz "@@@"
lista: .word 0					# Direccion del primer elemento. Se inicializa en nullptr cuando no hay elementos.


.text
  
# Pide un string por consola.
# No toma inputs.
#########################################
string:									#
  sub $sp, $sp, 8                       #
  sw $a0, 0($sp)                        #
  sw $a1, 4($sp)                        #
                                        #
  li $a0, STRING_MAX					#
  li $v0, 9								#
  syscall								#
										#
  move $a0, $v0 						# 
  li $a1, STRING_MAX    				#
  li $v0, 8								#
  syscall								# Pido el string.
										#
  move $v0, $a0     					# Pongo en $v0 la direccion del string alojado.
  lw $a0, 0($sp)                        #
  lw $a1, 4($sp)						#
  add $sp, $sp, 8                       #
  jr $ra								#
#########################################
# $v0 - Direccion de alojamiento del string


# Pone un elemento al final de la lista. Recordar que este elemento es una direccion.
# $a0 - direccion de la lista. Es decir, direccion donde esta almacenada la direccion del primer elemento.
# $a1 - direccion del elemento a agregar.
#########################################
listaPush:								#
  add $t0, $a0, 0						#
  add $t1, $a1, 0						# CAMBIAR A $SP
  lw $t2, ($a0)							# $t2 - Direccion del primer elemento.
										#
  bne $t2, $0, ListaNoVacia				# Si $t2 = 0 la lista esta vacia.
	li $a0, 8							#
    li $v0, 9							#
    syscall								# Alojo espacio para el nuevo elemento: 8 bytes.
    sw $v0, 0($t0)						#
  	j listaPush_return					#
  ListaNoVacia:                         #
                                        #
  listaPush_recorrer:					# Primero tengo que llegar al ultimo elemento.
    add $t2, $t2, OFFSET_DIRECCION		#
	lw $t3, ($t2)						# Veo la direccion del siguiente.
	beq $t3, $0, listaPush_finRecorrer	# Si la direccion del siguiente es 0, estoy en el ultimo elemento.
										#
	add $t2, $t3, 0 					# Paso al siguiente elemento de la lista.
	j listaPush_recorrer				#
  listaPush_finRecorrer:    			#
										#
  li $a0, 8								#
  li $v0, 9								#
  syscall								# Alojo espacio para el nuevo elemento: 8 bytes.
										#
  sw $v0, OFFSET_DIRECCION($t2)			#
										#
  listaPush_return:						#
										#
  sw $0, OFFSET_DIRECCION($v0)			# Como el nuevo elemento es el ultimo, la direccion del siguiente es 0.
  sw $t1, OFFSET_DATO($v0)				# Guardo el contenido del nuevo elemento.
										#
  add $a0, $t0, 0						#
  add $a1, $t1, 0						#
  jr $ra								#
#########################################

# Saca el primer elemento de la lista, y lo devuelve.
# $a0 - direccion de la lista. Es decir, direccion donde esta almacenada la direccion del primer elemento.
#########################################
listaPop:								#
  lw $t1, ($a0)							# $t1 - Direccion del primer elemento, el que voy a sacar.
  lw $t2, OFFSET_DIRECCION($t1)			# $t2 - Direccion del segundo elemento, el que se volverá el primero.
										#
  sw $t2, OFFSET_DIRECCION($a0)			# Almaceno la direccion del segundo elemento como el nuevo primero.
										#
  lw $v0, OFFSET_DATO($t1)				# Preparo la direccion que voy a retornar.
  jr $ra								#
#########################################
# $v0 - direccion del string popeado.

main:
jal string
move $a1, $v0
la $a0, lista
jal listaPush
jal listaPop
li $v0, 10
syscall
