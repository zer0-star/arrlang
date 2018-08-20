# arrlang: The best language powered by "ARROW"
It's compiled to C.
## example
```
func[int->int: fibonacci]<-n->{
  if((n, 2)-><)->{
    return<-n
  } else->{
    return<-((n, 1)->-->fibonacci, (n, 2)->-->fibonacci)->+
  }
}
func[void->int: main]<-{
  ("%d\n", 10->fibonacci)->printf
  return<-0
}
```
↓
```c
#include <stdio.h>
int fibonacci(int n){
  if (n < 2) {
    return n;
  } else {
    return fibonacci(n-1) + fibonacci(n-2);
  }
}
int main(void){
  printf("%d\n", fibonacci(10));
  return 0;
}
```

## usage
`arrlang -o test test.arr`  
options:  
-o:                    set output file  
-h:                    show help  
-i/--import/--include: set include files  
-r/--run:              run after compiling  
