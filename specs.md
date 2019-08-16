# Types to take into account when implementing code

It's in C notation, I'm very sorry.

### Input
```C
struct Input {
  void* value; // String
  int priority;
}
```

### Node
```C
struct Node {
  void* left; // Node
  void* right; // Node
  void* data; // LinkedList
  int priority;
}
```

### Data
```C
struct Data {
  void* value; // String
  void* next; // Data
}
```
