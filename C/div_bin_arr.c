#include <stdio.h>
#include <stdbool.h>
#include <math.h>

typedef struct fragment{
  int start;
  int end;
} fra;

int count(int w, int B[], int f, int l) {
  int ct=0;
  for (int i=f; i<l; i++)
    if (B[i] == w) {ct++;}
  if ( ct >= (int) ceil((l-f)/2) ) {return 1;}
  else {return 0;}
}

fra find_longest_sub(int w, int s, int e, int A[])
{
  int aw;
  int i;
  fra longest_sub;
  fra cand_sub;

  if (w == 0) {
    aw = 1;
    longest_sub.start=s;
    longest_sub.end=s+1;
    i=s;

    while (i < e){
      cand_sub.start=i; 
      while ( A[i] == w ) {i++;}
      cand_sub.end = i+1;
      if (longest_sub.end - longest_sub.start < cand_sub.end - cand_sub.start){
        longest_sub.end = cand_sub.end;
        longest_sub.start = cand_sub.start;
      } 
      i++;
      while (A[i] == aw && i < e) {i++;}
    }
  }
  else {
    aw = 0;
    longest_sub.start=e-1;
    longest_sub.end=e;
    i=e-1;

    while (i > s){
      cand_sub.end=i+1; 
      while ( A[i] == w ) {i--;}
      cand_sub.start = i+1;
      if (longest_sub.end - longest_sub.start < cand_sub.end - cand_sub.start){
        longest_sub.end = cand_sub.end;
        longest_sub.start = cand_sub.start;
      } 
      while (A[i] == aw && i > s) {i--;}
    }
  }
  return longest_sub;
}

int get_new_end(int start, int end, int A[])
{
  fra longest_sub_1 = find_longest_sub(1,start,end,A);
  if (count(1,A,start,longest_sub_1.start)) {return longest_sub_1.end;}
  else { 
    int s = longest_sub_1.start-1;
    while (s > start && A[s] == 0) {s--;}
    return s; 
  }
}

int get_new_start(int start, int end, int A[]) 
{
  fra longest_sub_0 = find_longest_sub(0,start,end,A);
  if (count(0,A,longest_sub_0.end,end)) {return longest_sub_0.start;}
  else {
    int s = longest_sub_0.end;
    while (s < end && A[s] == 1) {s++;}
    return s; 
  }
}

fra expand(int w, int s, int ss, int se, int e, int A[]){
  fra ex_frag;
  ex_frag.end = -1;
  ex_frag.start = -1;
  if (w == 0){
    if (count(0,A,se,e)) {ex_frag.end = e;}
    else {ex_frag.end = se;}
    if (count(0,A,s,ss)) {ex_frag.start = s;}
    else {
      int start = s;
      while (ss > start) { start = get_new_start(start,ss,A); }
      ex_frag.start = start;
    }
  }
  else {
    ex_frag.start = ss;
    if (count(1,A,se,e)) {ex_frag.end = e;}
    else {
      int end = e;
      while (se < end) { end = get_new_end(se,end,A); }
      ex_frag.end = end;
    }
  }
  return ex_frag;  
}

int solution(int A[], int N) {

  fra frag;
  int i=0;
  while (A[i] == 1 && i < N) {i++;}
  if (i == N) {printf("no solution, since no 0s in the array\n"); return 0;}
  frag.start=i;
  i=N-1;
  while (A[i] == 0 && i >=0) {i--;}
  if (i == -1) {printf("no solution, since no 1s in the array\n"); return 0;}
  frag.end=i+1;
  if (frag.start >= frag.end) {return 0;}
  if (frag.start == frag.end-2) {return 2;}
  int end = ceil((frag.end-frag.start)/2);
  end = frag.start + end;
  while (A[end] == 0) {end++;}
  fra longest_sub_0 = find_longest_sub(0,frag.start,end,A);
  fra longest_sub_1 = find_longest_sub(1,end,frag.end,A);
    fra first_part = expand(0,frag.start,longest_sub_0.start,longest_sub_0.end,longest_sub_1.start, A);
    fra second_part;
    second_part.start = first_part.end;
    second_part.end = longest_sub_1.end;
    second_part = expand(1,second_part.start,second_part.start,second_part.end,frag.end, A);

    if (first_part.start > 0 ){
      int ct=0;
      for ( i=first_part.start; i<first_part.end; i++)
        if (A[i] == 0) {ct++;}
      while (ct > (int) ceil((first_part.end-first_part.start+1)/2) && first_part.start >0 ){
        first_part.start--;
      }      
    }
    if (second_part.end < N ){
      int ct=0;
      for ( i=second_part.start; i < second_part.end; i++)
        if (A[i] == 1) {ct++;}
      while (ct > (int) ceil((second_part.end-second_part.start+1)/2) && second_part.end < N ){
        second_part.end++; 
      }
    } 

    printf("%d %d| %d\n", first_part.start, second_part.start, second_part.end);

    return second_part.end-first_part.start;

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
