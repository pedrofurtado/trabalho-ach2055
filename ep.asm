# EP1 - Arquitetura de Computadores
#
# Turma Matutino - 2016
#
# Nomes:
#   Pedro Felipe de Azevedo Furtado    n. USP: 9277194
#   Bruno Vinicius Brandao da Silva    n. USP: 9424058
#   Lucas Paulon Goncalves             n. USP: 9277750
#   Felipe Fernandes dos Santos        n. USP: 9276922

.data

mensagem_erro_abertura_arquivo_saida: .asciiz "\n Erro ao abrir arquivo de saida."
mensagem_erro_abertura_arquivo_A: .asciiz "\nO arquivo A nao pode ser aberto."
mensagem_erro_numero_argumentos: .asciiz "\nOs argumentos devem ser passados no formato <arquivo-A> <arquivo-B> <arquivo-Saida>."
mensagem_erro_abertura_arquivo_B: .asciiz "\nO arquivo B nao pode ser aberto."

		 .align 2
texto_arquivo_A: .space 200
        .align 2
vetorA: .space 30000
		 .align 2
texto_arquivo_B: .space 200
        .align 2
vetorB: .space 30000
	.align 2
vetorC: .space 30000
	     .align 2
bufferSaida: .space 200

.globl main

.text
main:
	blt $a0, 3, ERRO_NUMERO_ARGUMENTOS
	addi $sp, $sp, -8
	sw $a1, 0($sp)
	sw $a0, 4($sp)
	li $v0, 13
	li $a1, 0
	lw $t0, 0($sp)
	lw $a0, 0($t0)
	syscall
	blt $v0, $zero, ERRO_ABERTURA_ARQUIVO_A
	move $a0, $v0
	la $a1, texto_arquivo_A
	la $s0, vetorA
	addi $s1, $zero, 0
	addi $s3, $zero, -1
	addi $s4, $zero, 0
	addi $s5, $zero, 0

loop1:
	li $v0, 14
	li $a2, 1
	syscall
	beq $v0, $zero, FIM_ARQUIVO_A
	la $t1, texto_arquivo_A
	lw $t1, 0($t1)
	addi $t0, $zero, 13
	beq $t1, $t0, ACHOU_CARRIAGE_RETURN_OR_NEW_LINE
	addi $t0, $zero, 10
	beq $t1, $t0, ACHOU_CARRIAGE_RETURN_OR_NEW_LINE
	addi $t0, $zero, 32
	beq $t1, $t0, loop1
	addi $t0, $zero, 43
	beq $t1, $t0, loop1
	addi $t0, $zero, 9
	beq $t1, $t0, loop1
	addi $t0, $zero, 45
	bne $t1, $t0, pulaS5
	addi $s5, $zero, 1
	j loop1

pulaS5:
	andi $t2, $t1, 15
	sll $t3, $s1, 1
	sll $s1, $s1, 3
	add $s1, $s1, $t3
	add $s1, $s1, $t2
	addi $s4, $zero, 1
	j loop1

ACHOU_CARRIAGE_RETURN_OR_NEW_LINE:
	beq $s4, $zero, loop1
	addi $t4, $zero, 0
	beq $s5, $t4, pulaTornarNegativo
	sub $s1, $zero, $s1
	addi $s5, $zero, 0

pulaTornarNegativo:
	bge $s3, 0, verificaNumeroEIgual
	j pulaVerificacaoNumeroIgual

verificaNumeroEIgual:
	add $t4, $zero, $s3
	sll $t4, $t4, 2
	add $t4, $t4, $s0
	lw $t4, 0($t4)
	bne $t4, $s1, pulaVerificacaoNumeroIgual
	addi $s1, $zero, 0
	addi $s4, $zero, 0
	addi $s5, $zero, 0
	j loop1

pulaVerificacaoNumeroIgual:
	addi $s3, $s3, 1
	add $t4, $zero, $s3
	sll $t4, $t4, 2
	add $t4, $t4, $s0
	sw $s1, 0($t4)
	addi $s1, $zero, 0
	addi $s4, $zero, 0
	j loop1

FIM_ARQUIVO_A:
  	li   $v0, 16
  	syscall
	addi $s3, $s3, 1
	beq $s4, $zero, leituraArquivoB
	addi $t4, $zero, 0
	beq $s5, $t4, pulaTornarNegativo2
	sub $s1, $zero, $s1
	addi $s5, $zero, 0

pulaTornarNegativo2:
	bge $s3, 0, verificaNumeroEIgual2
	j pulaVerificacaoNumeroIgual2

verificaNumeroEIgual2:
	addi $t4, $s3, -1
	sll $t4, $t4, 2
	add $t4, $t4, $s0
	lw $t4, 0($t4)
	bne $t4, $s1, pulaVerificacaoNumeroIgual2
	addi $s1, $zero, 0
	addi $s4, $zero, 0
	addi $s5, $zero, 0
	j leituraArquivoB

pulaVerificacaoNumeroIgual2:
	addi $t4, $s3, 0
	sll $t4, $t4, 2
	add $t4, $t4, $s0
	sw $s1, 0($t4)
	addi $s1, $zero, 0
	addi $s4, $zero, 0
	addi $s3, $s3, 1
	j leituraArquivoB

leituraArquivoB:
	li $v0, 13
	li $a1, 0
	lw $t0, 0($sp)
	lw $a0, 4($t0)
	syscall
	blt $v0, $zero, ERRO_ABERTURA_ARQUIVO_B
	move $a0, $v0
	la $a1, texto_arquivo_B
	la $s7, vetorB
	addi $s1, $zero, 0
	addi $s6, $zero, -1
	addi $s4, $zero, 0
	addi $s5, $zero, 0

loop1B:
	li $v0, 14
	li $a2, 1
	syscall
	beq $v0, $zero, FIM_ARQUIVO_B
	la $t1, texto_arquivo_B
	lw $t1, 0($t1)
	addi $t0, $zero, 13
	beq $t1, $t0, ACHOU_CARRIAGE_RETURN_OR_NEW_LINEB
	addi $t0, $zero, 10
	beq $t1, $t0, ACHOU_CARRIAGE_RETURN_OR_NEW_LINEB
	addi $t0, $zero, 32
	beq $t1, $t0, loop1B
	addi $t0, $zero, 43
	beq $t1, $t0, loop1B
	addi $t0, $zero, 9
	beq $t1, $t0, loop1B
	addi $t0, $zero, 45
	bne $t1, $t0, pulaS5B
	addi $s5, $zero, 1
	j loop1B

pulaS5B:
	andi $t2, $t1, 15
	sll $t3, $s1, 1
	sll $s1, $s1, 3
	add $s1, $s1, $t3
	add $s1, $s1, $t2
	addi $s4, $zero, 1
	j loop1B

ACHOU_CARRIAGE_RETURN_OR_NEW_LINEB:
	beq $s4, $zero, loop1B
	addi $t4, $zero, 0
	beq $s5, $t4, pulaTornarNegativoB
	sub $s1, $zero, $s1
	addi $s5, $zero, 0

pulaTornarNegativoB:
	bge $s6, 0, verificaNumeroEIgualB
	j pulaVerificacaoNumeroIgualB

verificaNumeroEIgualB:
	add $t4, $zero, $s6
	sll $t4, $t4, 2
	add $t4, $t4, $s7
	lw $t4, 0($t4)
	bne $t4, $s1, pulaVerificacaoNumeroIgualB
	addi $s1, $zero, 0
	addi $s4, $zero, 0
	addi $s5, $zero, 0
	j loop1B

pulaVerificacaoNumeroIgualB:
	addi $s6, $s6, 1
	add $t4, $zero, $s6
	sll $t4, $t4, 2
	add $t4, $t4, $s7
	sw $s1, 0($t4)
	addi $s1, $zero, 0
	addi $s4, $zero, 0
	j loop1B

FIM_ARQUIVO_B:
  	li   $v0, 16
  	syscall
	addi $s6, $s6, 1
	beq $s4, $zero, concatenaAeBnoVetorC
	addi $t4, $zero, 0
	beq $s5, $t4, pulaTornarNegativo2B
	sub $s1, $zero, $s1
	addi $s5, $zero, 0

pulaTornarNegativo2B:
	bge $s6, 0, verificaNumeroEIgual2B
	j pulaVerificacaoNumeroIgual2B

verificaNumeroEIgual2B:
	addi $t4, $s6, -1
	sll $t4, $t4, 2
	add $t4, $t4, $s7
	lw $t4, 0($t4)
	bne $t4, $s1, pulaVerificacaoNumeroIgual2B
	addi $s1, $zero, 0
	addi $s4, $zero, 0
	addi $s5, $zero, 0
	j concatenaAeBnoVetorC

pulaVerificacaoNumeroIgual2B:
	addi $t4, $s6, 0
	sll $t4, $t4, 2
	add $t4, $t4, $s7
	sw $s1, 0($t4)
	addi $s1, $zero, 0
	addi $s4, $zero, 0
	addi $s6, $s6, 1
	j concatenaAeBnoVetorC

concatenaAeBnoVetorC:
	jal concatena
	j ordenaVetorC

concatena:
	la $s1, vetorC
	addi $t0, $zero, 0
	addi $t1, $zero, 0
	add $s2, $s3, $s6

loopwhile1:
	bge $t0, $s3, preencheVetorC
	addi $t1, $zero, 0

loopwhile1Interno:
	bge $t1, $s6, fimwhile1
	sll $t2, $t0, 2
	add $t2, $t2, $s0
	lw $t3, 0($t2)
	sll $t2, $t1, 2
	add $t2, $t2, $s7
	lw $t4, 0($t2)
	bne $t3, $t4, loopwhile1InternoElse
	addi $s2, $s2, -1

loopwhile1InternoElse:
	addi $t1, $t1, 1
	j loopwhile1Interno

fimwhile1:
	addi $t0, $t0, 1
	j loopwhile1

preencheVetorC:
	addi $t0, $zero, 0
	addi $t1, $zero, 0
	addi $t2, $zero, 0
	addi $t3, $zero, 0

loopwhile2:
	bge $t0, $s3, preencheVetorCRodada2
	addi $t1, $zero, 0
	addi $t3, $zero, 1

loopwhile2Interno:
	bge $t1, $s6, loopwhile2InternoElse
	sll $t4, $t0, 2
	add $t4, $t4, $s0
	lw $t5, 0($t4)
	sll $t4, $t1, 2
	add $t4, $t4, $s7
	lw $t6, 0($t4)
	bne $t5, $t6, loopwhile2InternoElse2
	sll $t4, $t2, 2
	add $t4, $t4, $s1
	sw $t5, 0($t4)
	addi $t2, $t2, 1
	addi $t3, $zero, 0
	j loopwhile2InternoElse

loopwhile2InternoElse2:
	addi $t1, $t1, 1
	j loopwhile2Interno

loopwhile2InternoElse:
	beq $t3, $zero, fimloopwhile2
	sll $t4, $t0, 2
	add $t4, $t4, $s0
	lw $t5, 0($t4)
	sll $t4, $t2, 2
	add $t4, $t4, $s1
	sw $t5, 0($t4)
	addi $t2, $t2, 1

fimloopwhile2:
	addi $t0, $t0, 1
	j loopwhile2

preencheVetorCRodada2:
	addi $t0, $zero, 0
	addi $t1, $zero, 0
	addi $t3, $zero, 0

loopwhile3:
	bge $t0, $s6, saidoConcatena
	addi $t1, $zero, 0
	addi $t3, $zero, 1

loopwhile3Interno:
	bge $t1, $s3, loopwhile3InternoElse
	sll $t4, $t0, 2
	add $t4, $t4, $s7
	lw $t5, 0($t4)
	sll $t4, $t1, 2
	add $t4, $t4, $s0
	lw $t6, 0($t4)
	bne $t5, $t6, loopwhile3InternoElse3
	addi $t3, $zero, 0
	j loopwhile3InternoElse

loopwhile3InternoElse3:
	addi $t1, $t1, 1
	j loopwhile3Interno

loopwhile3InternoElse:
	beq $t3, $zero, fimloopwhile3
	sll $t4, $t0, 2
	add $t4, $t4, $s7
	lw $t5, 0($t4)
	sll $t4, $t2, 2
	add $t4, $t4, $s1
	sw $t5, 0($t4)
	addi $t2, $t2, 1

fimloopwhile3:
	addi $t0, $t0, 1
	j loopwhile3

saidoConcatena:
	jr $ra

ordenaVetorC:
	addi $t0, $s2, -1
	addi $t1, $zero, 0
	addi $t2, $zero, 0

loopwhileOrdenacao:
	ble $t0, $zero, escreverArquivoSaida
	addi $t1, $zero, 0

loopinternowhileOrdenacao:
	bge $t1, $t0, fimloopwhileOrdenacao
	sll $t8, $t1, 2
	add $t8, $t8, $s1
	lw $t5, 0($t8)
	addi $t7, $t1, 1
	sll $t9, $t7, 2
	add $t9, $t9, $s1
	lw $t6, 0($t9)
	ble $t5, $t6, elseloopinternoOrdenacao
	add $t2, $zero, $t5
	sw $t6, 0($t8)
	sw $t2, 0($t9)

elseloopinternoOrdenacao:
	addi $t1, $t1, 1
	j loopinternowhileOrdenacao

fimloopwhileOrdenacao:
	addi $t0, $t0, -1
	j loopwhileOrdenacao

escreverArquivoSaida:
	li $v0, 13
	li $a1, 1
	lw $t0, 0($sp)
	lw $a0, 8($t0)
	syscall
	blt $v0, $zero, ERRO_ABERTURA_ARQUIVO_SAIDA
 	move $a0, $v0
 	addi $t0, $zero, 0

loopElementosVetorC:
 	bge $t0, $s2, FIM_ARQUIVO_C
 	addi $t3, $zero, 0
 	addi $t4, $zero, 1
 	sll $t1, $t0, 2
 	add $t1, $t1, $s1
 	lw $t1, 0($t1)
 	bge $t1, $zero, loopDivisao
 	sub $t1, $zero, $t1
 	addi $t3, $zero, 1

loopDivisao:
 	div $t2, $t1, 10
 	beq $t2, $zero, paraDivisao
 	addi $t4, $t4, 1
 	addi $sp, $sp, -4
 	mfhi $t5
 	sw $t5, 0($sp)
 	add $t1, $zero, $t2
 	j loopDivisao

paraDivisao:
 	addi $sp, $sp, -4
 	mfhi $t5
 	sw $t5, 0($sp)
 	beq $t3, $zero, colocaDigitosArquivo
 	li   $v0, 15
  	la   $a1, bufferSaida
  	addi $t7, $zero, 45
  	sw $t7, 0($a1)
  	li   $a2, 1
  	syscall

colocaDigitosArquivo:
	beq $t4, $zero, fimloopElementosVetorC
	lw $t5, 0($sp)
  	li   $v0, 15
  	la   $a1, bufferSaida
	addi $t5, $t5, 48
  	sw $t5, 0($a1)
  	li   $a2, 1
  	syscall
	addi $sp, $sp, 4
	addi $t4, $t4, -1
	j colocaDigitosArquivo

fimloopElementosVetorC:
 	li   $v0, 15
  	la   $a1, bufferSaida
  	addi $t7, $zero, 13
  	sw $t7, 0($a1)
  	li   $a2, 1
  	syscall
 	li   $v0, 15
  	la   $a1, bufferSaida
  	addi $t7, $zero, 10
  	sw $t7, 0($a1)
  	li   $a2, 1
  	syscall
 	addi $t0, $t0, 1
 	j loopElementosVetorC

ERRO_ABERTURA_ARQUIVO_SAIDA:
	la $a0, mensagem_erro_abertura_arquivo_saida
	li $v0, 4
	syscall
	j FIM

ERRO_ABERTURA_ARQUIVO_B:
	la $a0, mensagem_erro_abertura_arquivo_B
	li $v0, 4
	syscall
	j FIM

ERRO_ABERTURA_ARQUIVO_A:
	la $a0, mensagem_erro_abertura_arquivo_A
	li $v0, 4
	syscall
	j FIM

ERRO_NUMERO_ARGUMENTOS:
	la $a0, mensagem_erro_numero_argumentos
	li $v0, 4
	syscall
	j FIM

FIM_ARQUIVO_C:
  	li   $v0, 16
  	syscall
  	j FIM

FIM:
	li $v0, 10
	syscall
