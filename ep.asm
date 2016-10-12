##
# References.
#

# http://stackoverflow.com/q/16027871 - Abertura de arquivo em MIPS
# http://stackoverflow.com/a/16994463 - Argc e Argv[] em MIPS
# http://stackoverflow.com/a/16698890 - Ver!
# http://stackoverflow.com/a/37505359 - Ver!
# http://stackoverflow.com/questions/16648068/access-file-in-mips-using-mars-tool
# http://forum.codecall.net/topic/75145-read-from-a-file-that-has-1-word-per-line-on-2-lines/

##
# Espaco de dados.
#
.data

##
# Static strings.
#
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
##
# Buffers.
#
		 .align 2
texto_arquivo_A: .space 20000
        .align 2
vetorA: .space 2000000
		 .align 2
texto_arquivo_B: .space 20000
        .align 2
vetorB: .space 2000000

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
# COMMOM
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
	#andi $a0, $a0, 15					# Convert ASCII code to int (http://stackoverflow.com/a/18164316) # Tabela ASCII: http://www.theasciicode.com.ar/ascii-printable-characters/number-five-ascii-code-53.html
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
	#andi $a0, $a0, 15					# Convert ASCII code to int (http://stackoverflow.com/a/18164316) # Tabela ASCII: http://www.theasciicode.com.ar/ascii-printable-characters/number-five-ascii-code-53.html
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
	#andi $a0, $a0, 15					# Convert ASCII code to int (http://stackoverflow.com/a/18164316) # Tabela ASCII: http://www.theasciicode.com.ar/ascii-printable-characters/number-five-ascii-code-53.html
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
	#andi $a0, $a0, 15					# Convert ASCII code to int (http://stackoverflow.com/a/18164316) # Tabela ASCII: http://www.theasciicode.com.ar/ascii-printable-characters/number-five-ascii-code-53.html
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
	
	# Exit
	j FIM

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
