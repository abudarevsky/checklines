# Line Detection

Replace or refactor old chain detection toward Lines-style detection.

Target detector should find:

- horizontal lines
- vertical lines
- diagonal lines if desired
- 5+ same-color pieces
- 5+ same-type pieces

Recommended naming:

```text
LineDetector.gd
```

or refactor existing:

```text
ChainDetector.gd
```

into clearer Lines-style logic.

### Detection Rules

A valid line can be:

```text
same color, any type
same type, any color
```

Do not require pieces to attack each other for removal in the current target design.

