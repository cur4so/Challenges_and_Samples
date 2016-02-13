#include <stdio.h>

int solution (int A[], int N)
{

  int sum[N];
  int add,dist,end,start,i,minp;
  int min=N;
  int pos=0;

  if (N==1) {return 0;}
  if (N==2 && A[1] == 1 && A[0] == 0) {return 2;}
  if (N==2){return 0;}

  if (A[0] == 0) {add=-1;}
  else {add=1;}
  sum[0] = add;
  if (A[1] == 0) {add=-1;}
  else {add=1;}
  sum[1] = sum[0]+add;

  for (int i = 1; i < N-1; i++){    
    if (A[i+1] == 0) {add=-1;}
    else {add=1;}
    sum[i+1]=sum[i]+add;

    if (sum[i+1]>sum[i] && sum[i]<sum[i-1]){
      if (min > sum[i]) {
        min=sum[i];
        minp=i;
      }
      pos++;
    }
  }

  if (sum[N-1] == N || sum[N-1] == -N ) {return 0;}
  if (pos == 0 && sum[0] == -1 && sum[N-1] > sum[0]) {return N;}
  if (pos == 0 && sum[0] == -1 && sum[N-1] == sum[0]) {return N-1;} 
  if (pos == 0 && sum[0] == -1 && sum[N-1] < sum[0]) {
    i=N-1;
    while(sum[i] < sum[0]){i--;}
    return i;
  } 

  if (pos >0){
    i=N-1; 
    while (sum[i] < min+1) {i--;}
    end = i+1;
    i=0;
    if (sum[0] > 0){
      while (sum[i] < min+2 && i < minp) {i++;}
    } 
    start=i;
    dist = end - start;
    return dist;
  }

  return 0;

}

// ==============================

int main(int argc, char *argv[])
{
  int A[argc-1];
  for(int i = 1; i < argc; i++)
    if (*argv[i] == '1') {A[i-1] = 1;}
    else {A[i-1] = 0;}

  printf("max length: %d\n", solution(A, argc-1));
 
  return 0;
}
