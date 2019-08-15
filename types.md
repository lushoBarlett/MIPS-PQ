# Types to take into account when implementing code

It's in C notation, I'm very sorry.

### Input
```C
struct Input {
  void* value; // string
  int priority;
}
```

### Node
```C
struct Node {
  void* left; // Node
  void* right; // Node
  int priority;
}
```
