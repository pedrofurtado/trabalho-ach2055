# References
# http://stackoverflow.com/q/16027871 - Abertura de arquivo em MIPS
# http://stackoverflow.com/a/16994463 - Argc e Argv[] em MIPS
# http://stackoverflow.com/a/16698890 - Ver!
# http://stackoverflow.com/a/37505359 - Ver!
# http://stackoverflow.com/questions/16648068/access-file-in-mips-using-mars-tool
# http://forum.codecall.net/topic/75145-read-from-a-file-that-has-1-word-per-line-on-2-lines/

##
# Espaco de dados
#
.data
mensagem_erro_abertura_arquivo_A: .asciiz "O arquivo A nao pode ser aberto."
mensagem_erro_numero_argumentos: .asciiz "Os argumentos devem ser passados no formato <arquivo-A> <arquivo-B> <arquivo-Saida>."
		 .align 2
texto_arquivo_A: .space 20000
		 .align 2
vetorA: .space 20000

##
# Codigo principal do EP.
#
.globl main

.text
main:
	blt $a0, 3, ERRO_NUMERO_ARGUMENTOS

	##
	# Armazenamento dos parametros argc e argv[] na pilha
	#
	addi $sp, $sp, -8
	sw $a1, 0($sp) 						# 0($sp) = argv[]
	sw $a0, 4($sp)						# 4($sp) = argc
	
	##
	# Etapa 1.1
	#
	# Leitura do arquivo A
	#
	
	# Abertura do arquivo A
	li $v0, 13           					# Define syscall 13 (Open file)
	li $a1, 0            					# Define file flag (0 = read)
	lw $t0, 0($sp)         					# $t0 = argv[]
	lw $a0, 0($t0)						# $a0 = argv[0] (arquivo A)
	syscall
	
	# Tratamento de erro da abertura do arquivo A
	blt $v0, $zero, ERRO_ABERTURA_ARQUIVO_A			# if ($v0 == -1) then ERRO_ABERTURA_ARQUIVO_A
	
	# Leitura do arquivo A
	move $a0, $v0        					# $a0 = $v0 (file descriptor)
	li $v0, 14           					# Define syscall 14 (Read from file)
	la $a1, texto_arquivo_A        				# allocate space for the bytes loaded
	li $a2, 1         					# number of characters to be read
	syscall
	
	# Print integer
	la $a0, texto_arquivo_A        				# address of string to be printed
	lw $a0, 0($a0)						# $a0 = texto_arquivo_A[0] = first character of buffer
	#andi $a0, $a0, 15					# Convert ASCII code to int (http://stackoverflow.com/a/18164316)
								# Tabela ASCII: http://www.theasciicode.com.ar/ascii-printable-characters/number-five-ascii-code-53.html
	li $v0, 1           					# print string
	syscall
	
	# Exit
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
