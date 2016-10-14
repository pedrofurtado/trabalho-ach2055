/**
 * EP1 - Arquitetura de Computadores
 *
 * Turma Matutino - 2016
 *
 * Nomes:
 *   Pedro Felipe de Azevedo Furtado    n. USP: 9277194
 *   Bruno Vinicius Brandao da Silva    n. USP: 9424058
 *   Lucas Paulon Goncalves             n. USP: 9277750
 *   Felipe Fernandes dos Santos        n. USP: 9276922
 */

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>
#include <stdbool.h>

static int n;

int* concatena(int na, int* a, int nb, int* b) {

  int i;
  int j;
  int k;
  int diferente_de_todos;

  /**
   * ETAPA 2
   *
   * - Determinar o tamanho do vetor C[], analisando os valores dos vetores A[] e B[] e desconsiderando as duplicacoes
   * - Realizar o merge entre os vetores A[] e B[], no vetor C[], sem os valores duplicados
   */
  i = 0;
  j = 0;
  k = 0;
  diferente_de_todos = 0;
  n = na + nb;

  while(i < na) {

    j = 0;

    while(j < nb) {

      if(a[i] == b[j]) {

        n--;

        /* Debug */printf("\nNa analise entre A[] e B[] foi encontrado a repeticao do valor: %d\n", a[i]);
      }

      j++;
    }

    i++;
  }

  /* Debug */printf("\nO tamanho do vetor C[], sem as duplicacoes, e: %d\n", n);

  int* c = malloc(n * sizeof(int));

  /**
   * ETAPA 2.1
   *
   * - Preenchendo o vetor C[], percorrendo o vetor A[] (rodada A -> B),
   *   colocando os valores distintos e tambem os duplicados.
   */
  i = 0;
  j = 0;
  k = 0;
  diferente_de_todos = 0;

  while(i < na) {

    j = 0;
    diferente_de_todos = 1;

    while(j < nb) {

      if(a[i] == b[j]) {

        c[k] = a[i];

        /* Debug */printf("\nInserindo o valor duplicado %d no vetor C[]\n", a[i]);

        k++;
        diferente_de_todos = 0;
        break;
      }

      j++;
    }

    if(diferente_de_todos != 0) {

      c[k] = a[i];
      k++;

      /* Debug */printf("\nInserindo o valor nao-duplicado %d no vetor C[]\n", a[i]);
    }

    i++;
  }


  /**
   * ETAPA 2.2
   *
   * - Preenchendo o vetor C[], percorrendo o vetor B[] (rodada B -> A),
   *   colocando apenas os valores distintos (sem colocar os duplicados,
   *   pois eles ja foram inseridos na etapa 2.1).
   */
  i = 0;
  j = 0;
  diferente_de_todos = 0;

  while(i < nb) {

    j = 0;
    diferente_de_todos = 1;

    while(j < na) {

      if(b[i] == a[j]) {

        diferente_de_todos = 0;
        break;
      }

      j++;
    }

    if(diferente_de_todos != 0) {

      c[k] = b[i];
      k++;

      /* Debug */printf("\nInserindo o valor nao-duplicado %d no vetor C[]\n", b[i]);
    }

    i++;
  }

  return c;
}

int main(int argc, char *argv[]) {


  /**
   * ETAPA 1
   *
   * - Ler os dois arquivos de entrada (no formato "<nome-do-programa> <nome-arquivo-A> <nome-arquivo-B>")
   * - Definir o tamanho dos vetores A[] e B[]
   * - Preencher os vetores A[] e B[] com os valores presentes nos arquivos
   */
  FILE *arq_a;
  FILE *arq_b;
  FILE *arq_saida;
  int na;
  int nb;
  int num;
  int i;
  int j;
  int aux;
  int anterior;
  int e_primeiro;
  int temp;


  /**
   * ETAPA 1.1
   *
   * - Definir o tamanho do vetor A[] (variavel na)
   */
  na = 0;
  arq_a = fopen(argv[1], "r");

  if(arq_a != NULL) {

    /* Debug */printf("\nValores inteiros lidos no arquivo A: [ ");

    e_primeiro = 1;

    while((fscanf(arq_a,"%d\n", &num)) != EOF) {

      if(e_primeiro == 1) {
        na++;
        e_primeiro = 0;
        anterior = num;
        /* Debug */printf("%d, ", num);
      }
      else {
        if (num != anterior) {
          na++;
          anterior = num;
          /* Debug */printf("%d, ", num);
        }
      }
    }

    /* Debug */printf("]\n");printf("\nO tamanho do vetor A (variavel na) e: %d\n", na);

    fclose(arq_a);
  }


  /**
   * ETAPA 1.2
   *
   * - Preencher o vetor A[]
   */
  int a[na];
  arq_a = fopen(argv[1], "r");
  i = 0;

  if(arq_a != NULL) {

    e_primeiro = 1;

    while((fscanf(arq_a,"%d\n", &num)) != EOF) {

      if (e_primeiro == 1) {
        a[i] = num;
        i++;
        e_primeiro = 0;
        anterior = num;
      }
      else {
        if (num != anterior) {
          a[i] = num;
          i++;
          anterior = num;
        }
      }
    }

    fclose(arq_a);
  }

  /* Debug */int z;printf("\nVetor A: [ "); for (z = 0; z < na; z++) {printf("%d, ", a[z]);}printf("]\n");


  /**
   * ETAPA 1.3
   *
   * - Definir o tamanho do vetor B[] (variavel nb)
   */
  nb = 0;
  arq_b = fopen(argv[2], "r");

  if(arq_b != NULL) {

    e_primeiro = 1;

    /* Debug */printf("\nValores inteiros lidos no arquivo B: [ ");

    while((fscanf(arq_b,"%d\n", &num)) != EOF) {

      if(e_primeiro == 1) {
        nb++;
        e_primeiro = 0;
        anterior = num;
        /* Debug */printf("%d, ", num);
      }
      else {
        if (num != anterior) {
          nb++;
          anterior = num;
          /* Debug */printf("%d, ", num);
        }
      }
    }

    /* Debug */printf("]\n");printf("\nO tamanho do vetor B (variavel nb) e: %d\n", nb);

    fclose(arq_b);
  }


  /**
   * ETAPA 1.4
   *
   * - Preencher o vetor B[]
   */
  i = 0;
  int b[nb];
  arq_b = fopen(argv[2], "r");

  if(arq_b != NULL) {

    e_primeiro = 1;

    while((fscanf(arq_b,"%d\n", &num)) != EOF) {

      if (e_primeiro == 1) {
        b[i] = num;
        i++;
        e_primeiro = 0;
        anterior = num;
      }
      else {
        if (num != anterior) {
          b[i] = num;
          i++;
          anterior = num;
        }
      }
    }

    fclose(arq_b);
  }

  /* Debug */int zq; printf("\nVetor B: [ "); for (zq = 0; zq < nb; zq++) { printf("%d, ", b[zq]);} printf("]\n");


  int* c = concatena(na, a, nb, b);


  /* Debug */printf("\nVetor C: [ "); int l = 0; while(l < n) { printf("%d, ", c[l]); l++; } printf("]\n");


  /**
   * ETAPA 3
   *
   * - Ordenar o vetor C[] com o algoritmo BubbleSort
   */
  aux = 0;
  i = n - 1;

  while(i > 0) {

    j = 0;

    while(j < i) {

      if (c[j] > c[j + 1]) {

        aux = c[j];
        c[j] = c[j + 1];
        c[j + 1] = aux;
      }

      j++;
    }

    i--;
  }

  /* Debug */int r;printf("\nVetor C ordenado (ja sem duplicacao): [ ");for(r = 0; r < n; ++r){ printf("%d ",c[r]); }printf("]\n");


  /**
   * ETAPA 4
   *
   * - Escrever os valores do vetor C[], na ordem, no arquivo de saida passado como parametro em "argv"
   */
  arq_saida = fopen(argv[3], "w");

  if(arq_saida != NULL) {

    i = 0;

    while(i < n) {

      temp = c[i];
      fprintf(arq_saida, "%d\n", temp);
      i++;
    }

    fclose(arq_saida);
  }

  return 0;
}
