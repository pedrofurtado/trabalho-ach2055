##
# EP1 - Arquitetura de Computadores
#
# Turma Matutino - 2016
#
# Nomes:
#   Pedro Felipe de Azevedo Furtado    n. USP: 9277194
#   Bruno Vinicius Brandao da Silva    n. USP: 9424058
#   Lucas Paulon Goncalves             n. USP: 9277750
#   Felipe Fernandes dos Santos        n. USP: 9276922

##
# Espaco de dados.
#
.data

##
# Static strings.
#
mensagem_erro_abertura_arquivo_saida: .asciiz "\n Erro ao abrir arquivo de saida."
mensagem_erro_abertura_arquivo_A: .asciiz "\nO arquivo A nao pode ser aberto."
	  mensagem_fim_arquivo_A: .asciiz "\nFIM do arquivo A."
 mensagem_erro_numero_argumentos: .asciiz "\nOs argumentos devem ser passados no formato <arquivo-A> <arquivo-B> <arquivo-Saida>."
		     temp_string: .asciiz "\nLido o caracter (em codigo ASCII): "
		detectado_r_ou_n: .asciiz "\n Detectado barra-r ou barra-n!"
		msg_temp_vetor_A: .asciiz "\n Valores finais no vetor A: [ "
	  msg_temp_vetor_A_final: .asciiz " ]\n"
	 msg_temp_vetor_A_espaco: .asciiz ", "
	 
mensagem_erro_abertura_arquivo_B: .asciiz "\nO arquivo B nao pode ser aberto."
	  mensagem_fim_arquivo_B: .asciiz "\nFIM do arquivo B."
		msg_temp_vetor_B: .asciiz "\n Valores finais no vetor B: [ "
		
	     numero_total_vetorC: .asciiz "\n O valor final de nc sem as duplicacoes (vetor C) e: "
		msg_temp_vetor_C: .asciiz "\n Valores finais no vetor C (rodada A -> B): [ "
       msg_temp_vetor_C_rodada_b: .asciiz "\n Valores finais no vetor C (rodada B -> A): [ "
      msg_temp_vetor_C_ordenacao: .asciiz "\n Valores finais no vetor C (apos ordenacao): [ "
		
		msg_valor_K: .asciiz "\n Valor de K: [ "
		
		msg_nova_linha: .asciiz "\n"
		msg_sinal_menos: .asciiz "-"
##
# Buffers.
#
		 .align 2
texto_arquivo_A: .space 2000
        .align 2
vetorA: .space 10000
		 .align 2
texto_arquivo_B: .space 2000
        .align 2
vetorB: .space 10000
	.align 2
vetorC: .space 10000
	     .align 2
bufferSaida: .space 2000
##
# Main code of EP.
#
.globl main

##
# Fixed registers.
# FILE A
# $s0 = base address of vetorA
# $s3 = n of file A
#
# FILE B
# $s6 = n of file B
# $s7 = base address of vetorB
#
# FILE C
# $s1 = base address of vetorC
# $s2 = n of file C ($s3 + $s6)
#
# COMMOM (before concatenation)
# $s1 = sum acummulator
# $s4 = it has been identified a number?
# $s5 = is negative number?
#
#

.text
main:
	##
	# Handling of invalid parameters format "<file-A> <file-B> <file-output>".
	#
	blt $a0, 3, ERRO_NUMERO_ARGUMENTOS			# if (argc < 3) then ERRO_NUMERO_ARGUMENTOS

	##
	# Storage of argc and argv[] in stack
	#
	addi $sp, $sp, -8
	sw $a1, 0($sp) 						# 0($sp) = argv[]
	sw $a0, 4($sp)						# 4($sp) = argc
	
	##
	# Step 1.1
	#
	# Reading of file A
	#
	
	# Open the file A
	li $v0, 13           					# Define syscall 13 (Open file)
	li $a1, 0            					# Define file flag (0 = read)
	lw $t0, 0($sp)         					# $t0 = argv[]
	lw $a0, 0($t0)						# $a0 = argv[0] (file A)
	syscall
	
	# Handling of error in opening of file A
	blt $v0, $zero, ERRO_ABERTURA_ARQUIVO_A			# if ($v0 == -1, i.e., error in file opening) then ERRO_ABERTURA_ARQUIVO_A
	
	# Settings of base parameters from syscall 14, to read the file A
	move $a0, $v0        					# $a0 = $v0 (file descriptor)
	la $a1, texto_arquivo_A        				# Allocate space for the bytes loaded
	
	##### TEMPORARY
	# Set the current position in vetorA buffer.
	la $s0, vetorA						# $s0 = base address of vetorA (vetorA[0])
	
	# Set the sum acumulator.
	addi $s1, $zero, 0
	
	# Set the n.
	addi $s3, $zero, -1					# n = -1 (start with negative value, to facilite the insertion in vetorA. Your value is fixed later)
	
	# Set the indentifier of a number to false.
	addi $s4, $zero, 0					# $s4 = 0 (0 = false, 1 = true)
	
	# Set the indentifier of negative number to false.
	addi $s5, $zero, 0					# $s5 = 0 (0 = false, 1 = true)

loop1:
	# Read the next character in file A.
	li $v0, 14						# Define syscall 14 (Read from file)
	li $a2, 1 						# Number of characters to be read
	syscall							# Read it! (It saves automatically in buffer[0])
	
	# Handling for EOF in file A
	beq $v0, $zero, FIM_ARQUIVO_A				# if ($v0 = 0, i.e., EOF) then FIM_ARQUIVO_A
	
	# Get the ASCII code from character previously read and saved in buffer
	la $t1, texto_arquivo_A        				# $t1 = address of texto_arquivo_A
	lw $t1, 0($t1)						# $t1 = ASCII code of character in buffer[0]

	# Handling for \r
	addi $t0, $zero, 13					# $t0 = 13 = ASCII code for \r (carriage return) 
	beq $t1, $t0, ACHOU_CARRIAGE_RETURN_OR_NEW_LINE		# if ($t1 = \r) then ignore it and loop again

	# Handling for \n
	addi $t0, $zero, 10					# $t0 = 10 = ASCII code for \n (line feed or new line)
	beq $t1, $t0, ACHOU_CARRIAGE_RETURN_OR_NEW_LINE		# if ($t1 = \n) then ignore it and loop again
	
	# Handling for [space]
	addi $t0, $zero, 32					# $t0 = 32 = ASCII code for [space] (blank space)
	beq $t1, $t0, loop1					# if ($t1 = [space]) then ignore it and loop again
	
	# Handling for +
	addi $t0, $zero, 43					# $t0 = 43 = ASCII code for + (plus operator)
	beq $t1, $t0, loop1					# if ($t1 = +) then ignore it and loop again
	
	# Handling for \t (horizontal tab)
	addi $t0, $zero, 9					# $t0 = 9 = ASCII code for \t (horizontal tab)
	beq $t1, $t0, loop1					# if ($t1 = \t) then ignore it and loop again
	
	# Handling for -
	addi $t0, $zero, 45					# $t0 = 45 = ASCII code for - (subtraction operator)
	bne $t1, $t0, pulaS5					# if ($t1 != -) then ignore and jump the setting of $s5, i.e., the number is not negative.
	addi $s5, $zero, 1					# $s5 = 1 (it is a negative number) 
	j loop1							# ITs a negative number, to loop again to get the number, man!
	
pulaS5:
	
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	
	la $a0, temp_string	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1
	
	#-2 Print integer
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	
	la $a0, texto_arquivo_A        				# $a0 = address of texto_arquivo_A (address of string to be printed)
	lw $a0, 0($a0)						# $a0 = texto_arquivo_A[0] = first character of buffer
	#andi $a0, $a0, 15					# Convert ASCII code to int
	li $v0, 1           					
	syscall 						# Print string!
	
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	#-2
	
	# Convert ASCII code to number and acummulate it to $s1
	andi $t2, $t1, 15					# $t2 = conversion from ASCII code to int
	sll $t3, $s1, 1						# $t3 = $s1 * 2
	sll $s1, $s1, 3						# $s1 = $s1 * 8
	add $s1, $s1, $t3					# $s1 = ($s1 * 8) + ($s1 * 2) = ($s1 * 10)
	add $s1, $s1, $t2					# $s1 = ($s1 * 10) + $t2
	
	# Set the number identifier to true
	addi $s4, $zero, 1					# $s4 = 1 (true)
	
	j loop1

exibeVetorA:	
	addi $t0, $zero, -1					# $t0 = -1
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	
	la $a0, msg_temp_vetor_A	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1

exibeVetorALoopInterno:
	addi $t0, $t0, 1					# $t0++
	sll $t1, $t0, 2						# $t1 = $t0 * 4 (in words)
	add $t1, $t1, $s0					# $t1 = vetorA[$t0] = ($t0 * 4) + base address of vetorA
	
	#-2 Print integer
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	lw $a0, 0($t1)        				# $a0 = address of texto_arquivo_A (address of string to be printed)
	#lw $a0, 0($a0)						# $a0 = texto_arquivo_A[0] = first character of buffer
	#andi $a0, $a0, 15					# Convert ASCII code to int
	li $v0, 1           					
	syscall 						# Print string!
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	#-2
	
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	la $a0, msg_temp_vetor_A_espaco	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1
	
	addi $t1, $s3, -1 					# $t1 = n - 1
	blt $t0, $t1, exibeVetorALoopInterno			# de 0 até n - 1
	
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	la $a0, msg_temp_vetor_A_final	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1
	
	# Now, lets go read the file B.
	j leituraArquivoB

ACHOU_CARRIAGE_RETURN_OR_NEW_LINE:
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	la $a0, detectado_r_ou_n	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1

	# D2 - Handling for empty lines
	beq $s4, $zero, loop1					# if ($t4 = 0 (false)) go to loop1, because does not have any number to save in buffer. I.e., it is an empty line.

	# Check if is negative number
	addi $t4, $zero, 0					# $t4 = 0 
	beq $s5, $t4, pulaTornarNegativo			# if ($s5 == 0) go to pulaTornarNegativo, i.e., the number is not negative.
	sub $s1, $zero, $s1					# $s1 = -$s1 (sum - complete number)
	addi $s5, $zero, 0					# $s5 = 0 (reset identifier of negative number)
	
pulaTornarNegativo:
	# Check if number is equal to previous
	bge $s3, 0, verificaNumeroEIgual			# if ($s3 >= 0) if n is at least 1, verify if number is equal to previous.
	j pulaVerificacaoNumeroIgual				# else , if is the first number read, jump the verification

verificaNumeroEIgual:
	# Get the number in vetorA[n] (previous number)
	add $t4, $zero, $s3					# $t4 = $s3 (n)
	sll $t4, $t4, 2						# $t4 = $t4 * 4 (in words)
	add $t4, $t4, $s0					# $t4 = vetorA[n] = ($t4 * 4) + base address of vetorA[]
	lw $t4, 0($t4)						# $t4 = vetorA[n] (complete number), get the previous number read
	bne $t4, $s1, pulaVerificacaoNumeroIgual		# if($t4 != $s1), if the number read is not equal to previous, then go to pulaVerificacaoNumeroIgual
	addi $s1, $zero, 0					# else, so the number is equal to previous, then $s1 = 0 (reset sum acummulator)
	addi $s4, $zero, 0					# $s4 = 0 (false) - reset the number identifier
	addi $s5, $zero, 0					# $s5 = 0 (reset identifier of negative number)
	j loop1							# Go back to the loop1, ignoring this equal number

pulaVerificacaoNumeroIgual:
	# D1 - Acummulate $s1 and save to vetorA
	addi $s3, $s3, 1					# $s3 = n++
	add $t4, $zero, $s3					# $t4 = $s3
	sll $t4, $t4, 2						# $t4 = $t4 * 4 (in words)
	add $t4, $t4, $s0					# $t4 = vetorA[n] = ($t4 * 4) + base address of vetorA[]
	sw $s1, 0($t4)						# vetorA[n] = $s1 (complete number)
	addi $s1, $zero, 0					# $s1 = 0 (reset sum acummulator)
	addi $s4, $zero, 0					# $s4 = 0 (false) - reset the number identifier
	j loop1							# Go back to the loop1

FIM_ARQUIVO_A:	
	la $a0, mensagem_fim_arquivo_A        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	
	# FIx the value of n
	addi $s3, $s3, 1					# $s3 = n++ (at this instruction the value of n is correctly fixed)
	
	# D2 - Handling for empty lines
	beq $s4, $zero, exibeVetorA 				# if ($s4 == 0), if the last line not contains a number, continue and skip.
	
	# Check if is negative number
	addi $t4, $zero, 0					# $t4 = 0 
	beq $s5, $t4, pulaTornarNegativo2			# if ($s5 == 0) go to pulaTornarNegativo, i.e., the number is not negative.
	sub $s1, $zero, $s1					# $s1 = -$s1 (sum - complete number)
	addi $s5, $zero, 0					# $s5 = 0 (reset identifier of negative number)
	
pulaTornarNegativo2:
	##############
	# Check if number is equal to previous
	bge $s3, 0, verificaNumeroEIgual2			# if ($s3 >= 0) if n is at least 1, verify if number is equal to previous.
	j pulaVerificacaoNumeroIgual2				# else , if is the first number read, jump the verification

verificaNumeroEIgual2:
	# Get the number in vetorA[n] (previous number)
	addi $t4, $s3, -1					# $t4 = $s3 - 1 (n-1, because it is the last valid position in vetor A)
	sll $t4, $t4, 2						# $t4 = $t4 * 4 (in words)
	add $t4, $t4, $s0					# $t4 = vetorA[n] = ($t4 * 4) + base address of vetorA[]
	lw $t4, 0($t4)						# $t4 = vetorA[n] (complete number), get the previous number read
	bne $t4, $s1, pulaVerificacaoNumeroIgual2		# if($t4 != $s1), if the number read is not equal to previous, then go to pulaVerificacaoNumeroIgual2
	addi $s1, $zero, 0					# else, so the number is equal to previous, then $s1 = 0 (reset sum acummulator)
	addi $s4, $zero, 0					# $s4 = 0 (false) - reset the number identifier
	addi $s5, $zero, 0					# $s5 = 0 (reset identifier of negative number)
	j exibeVetorA						# Go back to the exibeVetorA, ignoring this equal number
	##############
	
pulaVerificacaoNumeroIgual2:
	# D1 - Acummulate $s1 and save to vetorA
	addi $t4, $s3, 0					# $t4 = $s3 = n++ (it is the last valid position in buffer)
	sll $t4, $t4, 2						# $t4 = $t4 * 4 (in words)
	add $t4, $t4, $s0					# $t4 = vetorA[n] = ($t4 * 4) + base address of vetorA[]
	sw $s1, 0($t4)						# vetorA[n] = $s1 (complete number)
	addi $s1, $zero, 0					# $s1 = 0 (reset sum acummulator)
	addi $s4, $zero, 0					# $s4 = 0 (false) - reset the number identifier	
	addi $s3, $s3, 1					# $s3 = n++
	j exibeVetorA
	
#######################
# Arquivo B 
#######################
leituraArquivoB:
	##
	# Storage of argc and argv[] in stack
	#
	#addi $sp, $sp, -8
	#sw $a1, 0($sp) 						# 0($sp) = argv[]
	#sw $a0, 4($sp)						# 4($sp) = argc
	
	##
	# Step 1.1
	#
	# Reading of file A
	#
	
	# Open the file A
	li $v0, 13           					# Define syscall 13 (Open file)
	li $a1, 0            					# Define file flag (0 = read)
	lw $t0, 0($sp)         					# $t0 = argv[]
	lw $a0, 4($t0)						# $a0 = argv[1] (file B)
	syscall
	
	# Handling of error in opening of file A
	blt $v0, $zero, ERRO_ABERTURA_ARQUIVO_B			# if ($v0 == -1, i.e., error in file opening) then ERRO_ABERTURA_ARQUIVO_A
	
	# Settings of base parameters from syscall 14, to read the file A
	move $a0, $v0        					# $a0 = $v0 (file descriptor)
	la $a1, texto_arquivo_B        				# Allocate space for the bytes loaded
	
	##### TEMPORARY
	# Set the current position in vetorA buffer.
	la $s7, vetorB						# $s0 = base address of vetorA (vetorA[0])
	
	# Set the sum acumulator.
	addi $s1, $zero, 0
	
	# Set the n.
	addi $s6, $zero, -1					# n = -1 (start with negative value, to facilite the insertion in vetorA. Your value is fixed later)
	
	# Set the indentifier of a number to false.
	addi $s4, $zero, 0					# $s4 = 0 (0 = false, 1 = true)
	
	# Set the indentifier of negative number to false.
	addi $s5, $zero, 0					# $s5 = 0 (0 = false, 1 = true)

loop1B:
	# Read the next character in file A.
	li $v0, 14						# Define syscall 14 (Read from file)
	li $a2, 1 						# Number of characters to be read
	syscall							# Read it! (It saves automatically in buffer[0])
	
	# Handling for EOF in file A
	beq $v0, $zero, FIM_ARQUIVO_B				# if ($v0 = 0, i.e., EOF) then FIM_ARQUIVO_A
	
	# Get the ASCII code from character previously read and saved in buffer
	la $t1, texto_arquivo_B        				# $t1 = address of texto_arquivo_A
	lw $t1, 0($t1)						# $t1 = ASCII code of character in buffer[0]

	# Handling for \r
	addi $t0, $zero, 13					# $t0 = 13 = ASCII code for \r (carriage return) 
	beq $t1, $t0, ACHOU_CARRIAGE_RETURN_OR_NEW_LINEB		# if ($t1 = \r) then ignore it and loop again

	# Handling for \n
	addi $t0, $zero, 10					# $t0 = 10 = ASCII code for \n (line feed or new line)
	beq $t1, $t0, ACHOU_CARRIAGE_RETURN_OR_NEW_LINEB		# if ($t1 = \n) then ignore it and loop again
	
	# Handling for [space]
	addi $t0, $zero, 32					# $t0 = 32 = ASCII code for [space] (blank space)
	beq $t1, $t0, loop1B					# if ($t1 = [space]) then ignore it and loop again
	
	# Handling for +
	addi $t0, $zero, 43					# $t0 = 43 = ASCII code for + (plus operator)
	beq $t1, $t0, loop1B					# if ($t1 = +) then ignore it and loop again
	
	# Handling for \t
	addi $t0, $zero, 9					# $t0 = 9 = ASCII code for \t (horizontal tab)
	beq $t1, $t0, loop1B					# if ($t1 = \t) then ignore it and loop again
	
	# Handling for -
	addi $t0, $zero, 45					# $t0 = 45 = ASCII code for - (subtraction operator)
	bne $t1, $t0, pulaS5B					# if ($t1 != -) then ignore and jump the setting of $s5, i.e., the number is not negative.
	addi $s5, $zero, 1					# $s5 = 1 (it is a negative number) 
	j loop1B							# ITs a negative number, to loop again to get the number, man!
	
pulaS5B:
	
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	
	la $a0, temp_string	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1
	
	#-2 Print integer
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	
	la $a0, texto_arquivo_B        				# $a0 = address of texto_arquivo_A (address of string to be printed)
	lw $a0, 0($a0)						# $a0 = texto_arquivo_A[0] = first character of buffer
	#andi $a0, $a0, 15					# Convert ASCII code to int
	li $v0, 1           					
	syscall 						# Print string!
	
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	#-2
	
	# Convert ASCII code to number and acummulate it to $s1
	andi $t2, $t1, 15					# $t2 = conversion from ASCII code to int
	sll $t3, $s1, 1						# $t3 = $s1 * 2
	sll $s1, $s1, 3						# $s1 = $s1 * 8
	add $s1, $s1, $t3					# $s1 = ($s1 * 8) + ($s1 * 2) = ($s1 * 10)
	add $s1, $s1, $t2					# $s1 = ($s1 * 10) + $t2
	
	# Set the number identifier to true
	addi $s4, $zero, 1					# $s4 = 1 (true)
	
	j loop1B

exibeVetorB:	
	addi $t0, $zero, -1					# $t0 = -1
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	
	la $a0, msg_temp_vetor_B	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1

exibeVetorBLoopInterno:
	addi $t0, $t0, 1					# $t0++
	sll $t1, $t0, 2						# $t1 = $t0 * 4 (in words)
	add $t1, $t1, $s7					# $t1 = vetorA[$t0] = ($t0 * 4) + base address of vetorA
	
	#-2 Print integer
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	
	lw $a0, 0($t1)        				# $a0 = address of texto_arquivo_A (address of string to be printed)
	#lw $a0, 0($a0)						# $a0 = texto_arquivo_A[0] = first character of buffer
	#andi $a0, $a0, 15					# Convert ASCII code to int
	li $v0, 1           					
	syscall 						# Print string!
	
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	#-2
	
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	
	la $a0, msg_temp_vetor_A_espaco	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1
	
	addi $t1, $s6, -1 					# $t1 = n - 1
	blt $t0, $t1, exibeVetorBLoopInterno			# de 0 até n - 1
	
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	
	la $a0, msg_temp_vetor_A_final	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1
	
	# When the printing of vetorB finished, lets go concatenate vetorA e vetorB in vetorC
	j concatenaAeBnoVetorC

ACHOU_CARRIAGE_RETURN_OR_NEW_LINEB:
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	la $a0, detectado_r_ou_n	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1

	# D2 - Handling for empty lines
	beq $s4, $zero, loop1B					# if ($t4 = 0 (false)) go to loop1, because does not have any number to save in buffer. I.e., it is an empty line.

	# Check if is negative number
	addi $t4, $zero, 0					# $t4 = 0 
	beq $s5, $t4, pulaTornarNegativoB			# if ($s5 == 0) go to pulaTornarNegativo, i.e., the number is not negative.
	sub $s1, $zero, $s1					# $s1 = -$s1 (sum - complete number)
	addi $s5, $zero, 0					# $s5 = 0 (reset identifier of negative number)
	
pulaTornarNegativoB:
	# Check if number is equal to previous
	bge $s6, 0, verificaNumeroEIgualB			# if ($s6 >= 0) if n is at least 1, verify if number is equal to previous.
	j pulaVerificacaoNumeroIgualB				# else , if is the first number read, jump the verification

verificaNumeroEIgualB:
	# Get the number in vetorA[n] (previous number)
	add $t4, $zero, $s6					# $t4 = $s6 (n)
	sll $t4, $t4, 2						# $t4 = $t4 * 4 (in words)
	add $t4, $t4, $s7					# $t4 = vetorA[n] = ($t4 * 4) + base address of vetorA[]
	lw $t4, 0($t4)						# $t4 = vetorA[n] (complete number), get the previous number read
	bne $t4, $s1, pulaVerificacaoNumeroIgualB		# if($t4 != $s1), if the number read is not equal to previous, then go to pulaVerificacaoNumeroIgual
	addi $s1, $zero, 0					# else, so the number is equal to previous, then $s1 = 0 (reset sum acummulator)
	addi $s4, $zero, 0					# $s4 = 0 (false) - reset the number identifier
	addi $s5, $zero, 0					# $s5 = 0 (reset identifier of negative number)
	j loop1B						# Go back to the loop1, ignoring this equal number

pulaVerificacaoNumeroIgualB:
	# D1 - Acummulate $s1 and save to vetorA
	addi $s6, $s6, 1					# $s6 = n++
	add $t4, $zero, $s6					# $t4 = $s6
	sll $t4, $t4, 2						# $t4 = $t4 * 4 (in words)
	add $t4, $t4, $s7					# $t4 = vetorA[n] = ($t4 * 4) + base address of vetorA[]
	sw $s1, 0($t4)						# vetorA[n] = $s1 (complete number)
	addi $s1, $zero, 0					# $s1 = 0 (reset sum acummulator)
	addi $s4, $zero, 0					# $s4 = 0 (false) - reset the number identifier
	j loop1B							# Go back to the loop1

FIM_ARQUIVO_B:	
	la $a0, mensagem_fim_arquivo_B        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	
	# FIx the value of n
	addi $s6, $s6, 1					# $s6 = n++ (at this instruction the value of n is correctly fixed)
	
	# D2 - Handling for empty lines
	beq $s4, $zero, exibeVetorB 				# if ($s4 == 0), if the last line not contains a number, continue and skip.
	
	# Check if is negative number
	addi $t4, $zero, 0					# $t4 = 0 
	beq $s5, $t4, pulaTornarNegativo2B			# if ($s5 == 0) go to pulaTornarNegativo, i.e., the number is not negative.
	sub $s1, $zero, $s1					# $s1 = -$s1 (sum - complete number)
	addi $s5, $zero, 0					# $s5 = 0 (reset identifier of negative number)
	
pulaTornarNegativo2B:
	##############
	# Check if number is equal to previous
	bge $s6, 0, verificaNumeroEIgual2B			# if ($s6 >= 0) if n is at least 1, verify if number is equal to previous.
	j pulaVerificacaoNumeroIgual2B				# else , if is the first number read, jump the verification

verificaNumeroEIgual2B:
	# Get the number in vetorA[n] (previous number)
	addi $t4, $s6, -1					# $t4 = $s6 - 1 (n-1, because it is the last valid position in vetor A)
	sll $t4, $t4, 2						# $t4 = $t4 * 4 (in words)
	add $t4, $t4, $s7					# $t4 = vetorA[n] = ($t4 * 4) + base address of vetorA[]
	lw $t4, 0($t4)						# $t4 = vetorA[n] (complete number), get the previous number read
	bne $t4, $s1, pulaVerificacaoNumeroIgual2B		# if($t4 != $s1), if the number read is not equal to previous, then go to pulaVerificacaoNumeroIgual2
	addi $s1, $zero, 0					# else, so the number is equal to previous, then $s1 = 0 (reset sum acummulator)
	addi $s4, $zero, 0					# $s4 = 0 (false) - reset the number identifier
	addi $s5, $zero, 0					# $s5 = 0 (reset identifier of negative number)
	j exibeVetorB						# Go back to the exibeVetorA, ignoring this equal number
	##############
	
pulaVerificacaoNumeroIgual2B:
	# D1 - Acummulate $s1 and save to vetorA
	addi $t4, $s6, 0					# $t4 = $s6 = n++ (it is the last valid position in buffer)
	sll $t4, $t4, 2						# $t4 = $t4 * 4 (in words)
	add $t4, $t4, $s7					# $t4 = vetorA[n] = ($t4 * 4) + base address of vetorA[]
	sw $s1, 0($t4)						# vetorA[n] = $s1 (complete number)
	addi $s1, $zero, 0					# $s1 = 0 (reset sum acummulator)
	addi $s4, $zero, 0					# $s4 = 0 (false) - reset the number identifier	
	addi $s6, $s6, 1					# $s6 = n++
	j exibeVetorB
#######################
# Arquivo B fecha
#######################


##############################
# Concatena A e B no vetor C
##############################
concatenaAeBnoVetorC:
	jal concatena
	j ordenaVetorC

concatena:

	la $s1, vetorC

	# i, j, nc
	addi $t0, $zero, 0					# i = 0
	addi $t1, $zero, 0					# j = 0
	add $s2, $s3, $s6					# nc = na + nb
	
loopwhile1:
	bge $t0, $s3, preencheVetorC				# if (i >= na), go to preencheVetorC
	addi $t1, $zero, 0					# j = 0
loopwhile1Interno:
	bge $t1, $s6, fimwhile1 				# if (j >= nb), go to fimwhile1
	
	# set a[i]
	sll $t2, $t0, 2						# $t2 = i * 4 (in words)
	add $t2, $t2, $s0					# $t2 = vetorA[$t2] = (i * 4) + base address of vetorA
	lw $t3, 0($t2)						# $t3 = a[i]

	# set b[j]	
	sll $t2, $t1, 2						# $t2 = j * 4 (in words)
	add $t2, $t2, $s7					# $t2 = vetorB[$t2] = (i * 4) + base address of vetorB
	lw $t4, 0($t2)						# $t4 = b[j]
	
	bne $t3, $t4, loopwhile1InternoElse			# if (a[i] != b[j]) go to loopwhile1InternoElse
	addi $s2, $s2, -1					# nc--
	
loopwhile1InternoElse:	
	addi $t1, $t1, 1					# j++
	j loopwhile1Interno

fimwhile1:
	addi $t0, $t0, 1					# i++
	j loopwhile1

preencheVetorC:
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	la $a0, numero_total_vetorC        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1
	
	#-2 Print integer
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	add $a0, $zero, $s2        				# $a0 = nc
	#lw $a0, 0($a0)						# $a0 = texto_arquivo_A[0] = first character of buffer
	#andi $a0, $a0, 15					# Convert ASCII code to int 
	li $v0, 1           					
	syscall 						# Print string!
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	#-2
	
	
	#i, j, k, diferente_de_todos
	addi $t0, $zero, 0					# i = 0
	addi $t1, $zero, 0					# j = 0
	addi $t2, $zero, 0					# k = 0
	addi $t3, $zero, 0					# diferente_de_todos = 0

loopwhile2:
	bge $t0, $s3, preencheVetorCRodada2			# if (i >= na) go to preencheVetorCRodada2
	addi $t1, $zero, 0					# j = 0
	addi $t3, $zero, 1					# diferente_de_todos = 1
	
loopwhile2Interno:
	bge $t1, $s6, loopwhile2InternoElse			# if (j >= nb) go to loopwhile2InternoElse
	
	# set a[i]
	sll $t4, $t0, 2						# $t4 = i * 4 (in words)
	add $t4, $t4, $s0					# $t4 = vetorA[$t4] = (i * 4) + base address of vetorA
	lw $t5, 0($t4)						# $t5 = a[i]

	# set b[j]	
	sll $t4, $t1, 2						# $t4 = j * 4 (in words)
	add $t4, $t4, $s7					# $t4 = vetorB[$t4] = (i * 4) + base address of vetorB
	lw $t6, 0($t4)						# $t6 = b[j]

	bne $t5, $t6, loopwhile2InternoElse2			# if (a[i] != b[j]) go to loopwhile2InternoElse2
	
	# set c[k]	
	sll $t4, $t2, 2						# $t4 = k * 4 (in words)
	add $t4, $t4, $s1					# $t4 = vetorC[$t4] = (i * 4) + base address of vetorC
	sw $t5, 0($t4)						# c[k] = a[i]
	addi $t2, $t2, 1					# k++
	addi $t3, $zero, 0					# diferente_de_todos = 0
	j loopwhile2InternoElse					# break;			

loopwhile2InternoElse2:
	addi $t1, $t1, 1					# j++
	j loopwhile2Interno	
	
loopwhile2InternoElse:
	beq $t3, $zero, fimloopwhile2				# if (diferente_de_todos == 0) go to fimloopwhile2
	
	# set a[i]
	sll $t4, $t0, 2						# $t4 = i * 4 (in words)
	add $t4, $t4, $s0					# $t4 = vetorA[$t4] = (i * 4) + base address of vetorA
	lw $t5, 0($t4)						# $t5 = a[i]

	# set c[k]	
	sll $t4, $t2, 2						# $t4 = k * 4 (in words)
	add $t4, $t4, $s1					# $t4 = vetorC[$t4] = (i * 4) + base address of vetorC
	sw $t5, 0($t4)						# c[k] = a[i]
	addi $t2, $t2, 1					# k++
	
fimloopwhile2:
	addi $t0, $t0, 1					# i++
	j loopwhile2
	
preencheVetorCRodada2:
###############-6 IMPRIME VETOR C
	addi $t0, $zero, -1					# $t0 = -1
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	la $a0, msg_temp_vetor_C	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1

exibeVetorCLoopInterno:
	addi $t0, $t0, 1					# $t0++
	sll $t1, $t0, 2						# $t1 = $t0 * 4 (in words)
	add $t1, $t1, $s1					# $t1 = vetorA[$t0] = ($t0 * 4) + base address of vetorA
	
	#-2 Print integer
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	lw $a0, 0($t1)        				# $a0 = address of texto_arquivo_A (address of string to be printed)
	#lw $a0, 0($a0)						# $a0 = texto_arquivo_A[0] = first character of buffer
	#andi $a0, $a0, 15					# Convert ASCII code to int 
	li $v0, 1           					
	syscall 						# Print string!
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	#-2
	
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	la $a0, msg_temp_vetor_A_espaco	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1
	
	addi $t1, $s2, -1 					# $t1 = n - 1
	blt $t0, $t1, exibeVetorCLoopInterno			# de 0 até n - 1
	
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	la $a0, msg_temp_vetor_A_final	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1
###############-6 IMPRIME VETOR C fecha

	# i, j, diferente_de_todos (o k nao e alterado, pois ja contem o valor certo)
	addi $t0, $zero, 0					# i = 0
	addi $t1, $zero, 0					# j = 0
	addi $t3, $zero, 0					# diferente_de_todos = 0
	
loopwhile3:
	bge $t0, $s6, saidoConcatena				# if (i >= nb) go to ordenaVetorC
	addi $t1, $zero, 0					# j = 0
	addi $t3, $zero, 1					# diferente_de_todos = 1
	
loopwhile3Interno:
	bge $t1, $s3, loopwhile3InternoElse			# if (j >= na) go to loopwhile3InternoElse
	
#######$$$
	# set b[i]
	sll $t4, $t0, 2						# $t4 = i * 4 (in words)
	add $t4, $t4, $s7					# $t4 = vetorB[$t4] = (i * 4) + base address of vetorB
	lw $t5, 0($t4)						# $t5 = b[i]

	# set a[j]	
	sll $t4, $t1, 2						# $t4 = j * 4 (in words)
	add $t4, $t4, $s0					# $t4 = vetorA[$t4] = (i * 4) + base address of vetorA
	lw $t6, 0($t4)						# $t6 = a[j]

	bne $t5, $t6, loopwhile3InternoElse3			# if (b[i] != a[j]) go to loopwhile2InternoElse2
	
	# set diferente_de_todos	
	addi $t3, $zero, 0					# diferente_de_todos = 0
	j loopwhile3InternoElse					# break;			

loopwhile3InternoElse3:
	addi $t1, $t1, 1					# j++
	j loopwhile3Interno	
	
loopwhile3InternoElse:
	beq $t3, $zero, fimloopwhile3				# if (diferente_de_todos == 0) go to fimloopwhile2
	
	# set b[i]
	sll $t4, $t0, 2						# $t4 = i * 4 (in words)
	add $t4, $t4, $s7					# $t4 = vetorB[$t4] = (i * 4) + base address of vetorB
	lw $t5, 0($t4)						# $t5 = b[i]

	# set c[k]	
	sll $t4, $t2, 2						# $t4 = k * 4 (in words)
	add $t4, $t4, $s1					# $t4 = vetorC[$t4] = (i * 4) + base address of vetorC
	sw $t5, 0($t4)						# c[k] = b[i]
	addi $t2, $t2, 1					# k++
#######$$$

fimloopwhile3:
	addi $t0, $t0, 1					# i++
	j loopwhile3

saidoConcatena:
	jr $ra
##############################
# Concatena A e B no vetor C fecha
##############################


#######################
# Ordenacao do vetor C
#######################
ordenaVetorC:
###############-6 IMPRIME VETOR C
	addi $t0, $zero, -1					# $t0 = -1
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	la $a0, msg_temp_vetor_C_rodada_b	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1

exibeVetorCLoopInterno2:
	addi $t0, $t0, 1					# $t0++
	sll $t1, $t0, 2						# $t1 = $t0 * 4 (in words)
	add $t1, $t1, $s1					# $t1 = vetorC[$t0] = ($t0 * 4) + base address of vetorC
	
	#-2 Print integer
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	lw $a0, 0($t1)        				# $a0 = address of texto_arquivo_A (address of string to be printed)
	#lw $a0, 0($a0)						# $a0 = texto_arquivo_A[0] = first character of buffer
	#andi $a0, $a0, 15					# Convert ASCII code to int 
	li $v0, 1           					
	syscall 						# Print string!
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	#-2
	
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	la $a0, msg_temp_vetor_A_espaco	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1
	
	addi $t1, $s2, -1 					# $t1 = n - 1
	blt $t0, $t1, exibeVetorCLoopInterno2			# de 0 até n - 1
	
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	la $a0, msg_temp_vetor_A_final	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1
###############-6 IMPRIME VETOR C fecha

	# i, j, aux
	addi $t0, $s2, -1					# i = nc - 1
	addi $t1, $zero, 0					# j = 0
	addi $t2, $zero, 0					# aux = 0
	
loopwhileOrdenacao:
	ble $t0, $zero, escreverArquivoSaida			# if (i <= 0) go to escreverArquivoSaida
	addi $t1, $zero, 0					# j = 0

loopinternowhileOrdenacao:
	bge $t1, $t0, fimloopwhileOrdenacao			# if (j >= i) go to fimloopwhileOrdenacao
	
	# set c[j]
	sll $t8, $t1, 2						# $t8 = j * 4 (in words)
	add $t8, $t8, $s1					# $t8 = vetorC[$t8] = (j * 4) + base address of vetorC
	lw $t5, 0($t8)						# $t5 = c[j]

	# set c[j+1]	
	addi $t7, $t1, 1					# $t7 = j + 1
	sll $t9, $t7, 2						# $t9 = (j+1) * 4 (in words)
	add $t9, $t9, $s1					# $t9 = vetorC[$t9] = ((j+1) * 4) + base address of vetorC
	lw $t6, 0($t9)						# $t6 = c[j+1]
	
	ble $t5, $t6, elseloopinternoOrdenacao			# if (c[j] <= c[j + 1]) go to elseloopinternoOrdenacao
	add $t2, $zero, $t5					# aux = c[j]
	sw $t6, 0($t8)						# c[j] = c[j+1]
	sw $t2, 0($t9)						# c[j+1] = aux

elseloopinternoOrdenacao:
	addi $t1, $t1, 1					# j++
	j loopinternowhileOrdenacao

fimloopwhileOrdenacao:
	addi $t0, $t0, -1					# i--
	j loopwhileOrdenacao

#######################
# Ordenacao do vetor C fecha
#######################


#########################
# Escrever arquivo saida
#########################
escreverArquivoSaida:
###############-6 IMPRIME VETOR C
	addi $t0, $zero, -1					# $t0 = -1
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	la $a0, msg_temp_vetor_C_ordenacao	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1

exibeVetorCLoopInterno3:
	addi $t0, $t0, 1					# $t0++
	sll $t1, $t0, 2						# $t1 = $t0 * 4 (in words)
	add $t1, $t1, $s1					# $t1 = vetorC[$t0] = ($t0 * 4) + base address of vetorC
	
	#-2 Print integer
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	lw $a0, 0($t1)        				# $a0 = address of texto_arquivo_A (address of string to be printed)
	#lw $a0, 0($a0)						# $a0 = texto_arquivo_A[0] = first character of buffer
	#andi $a0, $a0, 15					# Convert ASCII code to int 
	li $v0, 1           					
	syscall 						# Print string!
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	#-2
	
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	la $a0, msg_temp_vetor_A_espaco	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1
	
	addi $t1, $s2, -1 					# $t1 = n - 1
	blt $t0, $t1, exibeVetorCLoopInterno3			# de 0 até n - 1
	
	# -1 Print temp string
	# Prepare stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $v0, 4($sp)
	la $a0, msg_temp_vetor_A_final	        			# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	# Reset stack
	lw $a0, 0($sp)
	lw $v0, 4($sp)
	addi $sp, $sp, 8
	## -1
###############-6 IMPRIME VETOR C fecha
	
###***	
	# Open the file C to prepare to write (create it, if not exists)
	li $v0, 13           					# Define syscall 13 (Open file)
	li $a1, 1            					# Define file flag (1 = write)
	lw $t0, 0($sp)         					# $t0 = argv[]
	lw $a0, 8($t0)						# $a0 = argv[2] (file output)
	syscall
	
	# Handling of error in opening of file A
	blt $v0, $zero, ERRO_ABERTURA_ARQUIVO_SAIDA		# if ($v0 == -1, i.e., error in file output opening) then ERRO_ABERTURA_ARQUIVO_SAIDA
	
	# Write in file C
 	move $a0, $v0      					# $a0 = file descriptor 
 	
 	# i, for write in file C
 	addi $t0, $zero, 0					# i = 0 (internal counter for loop)
 	
loopElementosVetorC:
 	bge $t0, $s2, FIM					# if ($t0 >= nc) go to FIM
 	
 	# set negative number identifier
 	addi $t3, $zero, 0					# $t3 = 0 (0 = positive, 1 = negative)
 	
 	# number of digits
 	addi $t4, $zero, 1					# $t4 = 1 (number of digits, at least 1)
 	
 	# set vetorC[i]
 	sll $t1, $t0, 2						# $t1 = i * 4 (in words)
 	add $t1, $t1, $s1					# $t1 = (i * 4) + base address of vetorC
 	lw $t1, 0($t1)						# $t1 = vetorC[i]
 	
 	bge $t1, $zero, loopDivisao				# if (vetorC[i] >= 0) go to loopDivisao 
 	sub $t1, $zero, $t1					# $t1 = 0 - (-$t1) = $t1 (same number but positive)
 	addi $t3, $zero, 1					# $t3 = 1 (is negative number!)

loopDivisao:
 	div $t2, $t1, 10					# $t2 = vetorC[i] / 10 (quotient)
 	
 	beq $t2, $zero, paraDivisao				# if (vetorC[i]/ 10 == 0) go to paraDivisao
 	
 	addi $t4, $t4, 1					# $t4++ (increase number of digits)
 	
 	# set stack with resto da divisao
 	addi $sp, $sp, -4					# open a position in stack
 	mfhi $t5						# $t5 = resto da divisao
 	sw $t5, 0($sp)						# pilha[ultima_posicao] = $t5
 	
 	# set the new sub-number
 	add $t1, $zero, $t2					# $t1 = vetorC[i] / 10
 	j loopDivisao 	
 
paraDivisao:

	# set stack with resto da divisao (last digit, more at left)
 	addi $sp, $sp, -4					# open a position in stack
 	mfhi $t5						# $t5 = resto da divisao
 	sw $t5, 0($sp)						# pilha[ultima_posicao] = $t5
 	
 	beq $t3, $zero, colocaDigitosArquivo			# if ($t3 == 0, i.e., if is a positive number) go to colocaDigitosArquivo
	
	# Write "-"
 	li   $v0, 15						# Define syscall 15 (write in file)
  	la   $a1, bufferSaida  					# address of buffer from which to write
  	addi $t7, $zero, 45					# -
  	sw $t7, 0($a1)
  	li   $a2, 1      					# hardcoded buffer length
  	syscall

colocaDigitosArquivo:

	beq $t4, $zero, fimloopElementosVetorC				# if ($t4 == 0) go to fimloopElementosVetorC
	
	lw $t5, 0($sp)							# $t5 = digit more at left
	
	# write digit
  	li   $v0, 15						# Define syscall 15 (write in file)
  	la   $a1, bufferSaida  					# address of buffer from which to write
	addi $t5, $t5, 48					# $t5 = $t5 + 48 (Convert to ASCII code for that number)
  	sw $t5, 0($a1)
  	li   $a2, 1      					# hardcoded buffer length
  	syscall
	
	addi $sp, $sp, 4						# up the stack
	
	addi $t4, $t4, -1						# $t4-- (decrease number of digits)
	j colocaDigitosArquivo

fimloopElementosVetorC:
	# Write "\r"
 	li   $v0, 15						# Define syscall 15 (write in file)
  	la   $a1, bufferSaida  					# address of buffer from which to write
  	addi $t7, $zero, 13					# \r
  	sw $t7, 0($a1)
  	li   $a2, 1      					# hardcoded buffer length
  	syscall
  	
  	# Write "\n"
 	li   $v0, 15						# Define syscall 15 (write in file)
  	la   $a1, bufferSaida  					# address of buffer from which to write
  	addi $t7, $zero, 10					# \n
  	sw $t7, 0($a1)
  	li   $a2, 1      					# hardcoded buffer length
  	syscall
  	
 	addi $t0, $t0, 1					# i++
 	j loopElementosVetorC	
 			
 	# Write -
 	#li   $v0, 15						# Define syscall 15 (write in file)
  	#la   $a1, vetorC  					# address of buffer from which to write
	#addi $t0, $zero, 45
  	#sw $t0, 0($a1)
  	#li   $a2, 1      					# hardcoded buffer length
  	#syscall            					# Write it!
  	
  	# write 7
  	#li   $v0, 15						# Define syscall 15 (write in file)
  	#la   $a1, vetorC  					# address of buffer from which to write
	#addi $t0, $zero, 55
  	#sw $t0, 0($a1)
  	#li   $a2, 1      					# hardcoded buffer length
  	#syscall            					# Write it!
  	
  	#j FIM
###***
#########################
# Escrever arquivo saida
#########################

ERRO_ABERTURA_ARQUIVO_SAIDA:
	la $a0, mensagem_erro_abertura_arquivo_saida        	# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	j FIM
	
ERRO_ABERTURA_ARQUIVO_B:
	la $a0, mensagem_erro_abertura_arquivo_B        	# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	j FIM

ERRO_ABERTURA_ARQUIVO_A:
	la $a0, mensagem_erro_abertura_arquivo_A        	# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	j FIM

ERRO_NUMERO_ARGUMENTOS:
	la $a0, mensagem_erro_numero_argumentos        	# address of string to be printed
	li $v0, 4           					# Set syscall 4 (print string)
	syscall
	j FIM

FIM:
	li $v0, 10						# Define syscall 10 (exit)
	syscall							# exit - return 0;
