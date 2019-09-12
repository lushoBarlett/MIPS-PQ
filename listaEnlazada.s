# Implementación de lista enlazada.
# La lista almacena punteros a strings.
# Entonces cada elemento consta de un puntero a un char y un puntero al proximo elemento.
# Estos punteros son words, cada elemento ocupa 8 bytes (4 para el nodo* y 4 para el char*).
# En esta implementación, 0 representa null para las direcciones.

.data
OFFSET_DIRECCION = 0			# Offset desde la direccion de un elemento y la direccion del siguiente.
OFFSET_DATO	= 4					# Offset desde la direccion de un elemento y su dato almacenado.
STRING_MAX = 4					# Máxima cantidad de caracteres para los strings entrados con la funcion string.

#lista: .word 0					# Direccion del primer elemento. Se inicializa en 0 cuando no hay elementos.


.text
  
# Pide un string por consola.
# No toma inputs.
#########################################
string:									#
  li $t0, 2								# Cada caracter ocupa dos bits.
  mul $t1, $t0, STRING_MAX				# $t1 - Cantidad de bits maximos para el string.
										#
  div $a0, $t1, 8						# $a0 - Cantidad de bytes para acomodar el max_string.
										#
  li $v0, 9								#
  syscall								#
										#
  addi $a0, $v0, 0						# 
  addi $a1, $0, STRING_MAX				#
  li $v0, 8								#
  syscall								# Pido el string.
										#
  addi $v0, $a0, 0						# Pongo en $v0 la direccion del string alojado.
										#
  jr $ra								#
#########################################
# $v0 - Direccion de alojamiento del string


# Pone un elemento al final de la lista. Recordar que este elemento es una direccion.
# $a0 - direccion de la lista. Es decir, direccion donde esta almacenada la direccion del primer elemento.
# $a1 - direccion del elemento a agregar.
#########################################
listaPush:								#
  addi $t0, $a0, 0						#
  addi $t1, $a1, 0						#
  lw $t2, ($a0)							# $t2 - Direccion del primer elemento.
										#
  beq $t2, $0, ListaVacia				# Si $t2 = 0 la lista esta vacia.
										#
  Recorrer:								# Primero tengo que llegar al ultimo elemento.
    addi $t2, $t2, OFFSET_DIRECCION		#
	lw $t3, ($t2)						# Veo la direccion del siguiente.
	beq $t3, $0, FinRecorrer			# Si la direccion del siguiente es 0, estoy en el ultimo elemento.
										#
	addi $t2, $t3, 0					# Paso al siguiente elemento de la lista.
	j Recorrer							#
  FinRecorrer:							#
										#
  li $a0, 8								#
  li $v0, 9								#
  syscall								# Alojo espacio para el nuevo elemento: 8 bytes.
										#
  sw $v0, 0($t2)						#
										#
  FinVacia:								#
										#
  addi $t2, $v0, 0						# $t2 - Direccion del nuevo elemento.
										#
  sw $0, 0($t2)							# Como el nuevo elemento es el ultimo, la direccion del siguiente es 0.
										#
  addi $t2, $t2, OFFSET_DATO			# Me muevo a la segunda componenete del nuevo elemento.
  sw $t1, 0($t2)						# Guardo el contenido del nuevo elemento.
										#
  addi $a0, $t0, 0						#
  addi $a1, $t1, 0						#
  jr $ra								#
										#
  ListaVacia:							# Caso particular en que tengo que agregar el primer elemento.
    li $a0, 8							#
    li $v0, 9							#
    syscall								# Alojo espacio para el nuevo elemento: 8 bytes.
										#
  sw $v0, 0($t0)						#
										#
  j FinVacia							#
										#
#########################################
# Esta funcion no retorna nada.

# Saca el primer elemento de la lista, y lo devuelve.
# $a0 - direccion de la lista. Es decir, direccion donde esta almacenada la direccion del primer elemento.
#########################################
listaPop:								#
  addi $t0, $a0, 0						#
										#
  lw $t1, ($t0)							# $t1 - Direccion del primer elemento, el que voy a sacar.
  lw $t2, ($t1)							# $t2 - Direccion del segundo elemento, el que se volverá primero.
										#
  sw $t2, 0($t0)						# Almaceno la direccion del segundo elemento como el nuevo primero.
										#
  addi $t1, $t1, OFFSET_DATO			# Me muevo a la segunda componenete del elemento que estoy popeando.
  lw $v0, ($t1)							# Preparo la direccion que voy a retornar.
										#
  addi $a0, $t0, 0						#
  jr $ra								#
#########################################
# $v0 - direccion del string popeado.