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
      }

      j++;
    }

    i++;
  }

  int* c = malloc(n * sizeof(int));

  /**
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

        k++;
        diferente_de_todos = 0;
        break;
      }

      j++;
    }

    if(diferente_de_todos != 0) {

      c[k] = a[i];
      k++;
    }

    i++;
  }


  /**
   * - Preenchendo o vetor C[], percorrendo o vetor B[] (rodada B -> A),
   *   colocando apenas os valores distintos (sem colocar os duplicados,
   *   pois eles ja foram inseridos).
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
    }

    i++;
  }

  return c;
}

int main(int argc, char *argv[]) {

  /**
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
   * - Definir o tamanho do vetor A[] (variavel na)
   */
  na = 0;
  arq_a = fopen(argv[1], "r");

  if(arq_a != NULL) {

    e_primeiro = 1;

    while((fscanf(arq_a,"%d\n", &num)) != EOF) {

      if(e_primeiro == 1) {
        na++;
        e_primeiro = 0;
        anterior = num;
      }
      else {
        if (num != anterior) {
          na++;
          anterior = num;
        }
      }
    }

    fclose(arq_a);
  }
  else {
    printf("\nErro na leitura do arquivo A.");
    return 0;
  }


  /**
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
  else {
    printf("\nErro na leitura do arquivo A.");
    return 0;
  }


  /**
   * - Definir o tamanho do vetor B[] (variavel nb)
   */
  nb = 0;
  arq_b = fopen(argv[2], "r");

  if(arq_b != NULL) {

    e_primeiro = 1;

    while((fscanf(arq_b,"%d\n", &num)) != EOF) {

      if(e_primeiro == 1) {
        nb++;
        e_primeiro = 0;
        anterior = num;
      }
      else {
        if (num != anterior) {
          nb++;
          anterior = num;
        }
      }
    }

    fclose(arq_b);
  }
  else {
    printf("\nErro na leitura do arquivo B.");
    return 0;
  }


  /**
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
  else {
    printf("\nErro na leitura do arquivo B.");
    return 0;
  }

  int* c = concatena(na, a, nb, b);

  /**
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

  /**
   * - Escrever os valores do vetor C[], em ordem, no arquivo de saida passado como parametro em "argv"
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
  else {
    printf("\nErro na leitura do arquivo C.");
    return 0;
  }

  return 0;
}
