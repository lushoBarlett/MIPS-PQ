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

### Actual structure
Similar to this C++ thing
```C++
vector<Node> heap;
```

We will use [this implementation](https://www.geeksforgeeks.org/binary-heap/).
