# Implementación de lista enlazada.
# La lista almacena punteros a strings.
# Entonces cada elemento consta de un puntero a un char y un puntero al proximo elemento.
# Estos punteros son words, cada elemento ocupa 8 bytes (4 para el nodo* y 4 para el char*).
# En esta implementación, 0 representa null para las direcciones.

.data
lista: .word 0					# Direccion del primer elemento. Se inicializa en 0 cuando no hay elementos.
OFFSET_DIRECCION = 0			# Offset desde la direccion de un elemento y la direccion del siguiente
OFFSET_DATO	= 32				# Offset desde la direccion de un elemento y su dato almacenado
elemTest: .asciiz "Hola capo"
elemTest2: .asciiz "Que onda man"

.text

main:
  la $a1, elemTest
  la $a0, lista
  jal listaPush
  
  la $a1, elemTest2
  la $a0, lista
  jal listaPush
  
  li $v0, 10
  syscall
  

# Pone un elemento al final de la lista. Recordar que este elemento es una direccion.
# $a0 - direccion de la lista.
# $a1 - direccion del elemento a agregar.
#########################################
listaPush:								#
  addi $t0, $a0, 0						#
  addi $t1, $a1, 0						#
  lw $t2, lista($0)						# $t2 - Direccion del primer elemento.
										#
  beq $t2, $0, FinRecorrer				# Si $t2 = 0 la lista esta vacia.
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
  addi $t2, $v0, 0						# $t2 - Direccion del nuevo elemento.
										#
  sw $v0, 0($t0)						# Hago que el ex-ultimo elemento "apunte" al nuevo.
										#
  sw $0, 0($t2)							# Como el nuevo elemento es el ultimo, la direccion del siguiente es 0.
										#
  addi $t2, $t2, OFFSET_DATO			# Me muevo a la segunda componenete del nuevo elemento.
  sw $t1, 0($t2)						# Guardo el contenido del nuevo elemento.
										#
  addi $a0, $t0, 0						#
  addi $a1, $t1, 0						#
  jr $ra								#
#########################################
# Esta funcion no retorna nada.