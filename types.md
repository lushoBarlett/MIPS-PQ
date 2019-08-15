# Types to take into account when implementing code

It's in C notation, I'm very sorry.

### Input
```C
struct Input {
  string value;
  int priority;
}
```

### Node
```C
struct Node {
  void* left;
  void* right;
  int priority;
}
```
