---
title: Rosé Pine Glow sample
description: Fixture for previewing Glamour styles
---

# Heading one

## Heading two

### Heading three

#### Heading four

##### Heading five

###### Heading six

All natural pine, faux fur and a bit of soho vibes for the classy minimalist.

**Bold text**, *italic text*, and ~~strikethrough~~. Inline `code` in a sentence.

> Block quotes use muted tones and stay readable beside body copy.

- Bullet one
- Bullet two
  - Nested bullet

1. First item
2. Second item
3. Third item

- [x] Completed task
- [ ] Open task

[Charm Glow](https://github.com/charmbracelet/glow) renders this file. [Rosé Pine](https://rosepinetheme.com/) supplies the palette.

---


| Variant | Base     | Mood        |
| ------- | -------- | ----------- |
| Main    | `#191724` | Cozy dark   |
| Moon    | `#232136` | Soft night  |
| Dawn    | `#faf4ed` | Warm light  |

### Bash

```bash
#!/usr/bin/env bash
export GLOW_STYLE="$HOME/.config/glow/styles/rose-pine-moon.json"
glow -s "$GLOW_STYLE" examples/sample.md
```

### Go

```go
package main

import "fmt"

func greet(name string) {
	fmt.Printf("Hello, %s\n", name)
}

func main() {
	greet("Rosé Pine")
}
```

### JSON

```json
{
  "style": "rose-pine-moon",
  "variants": ["rose-pine", "rose-pine-moon", "rose-pine-dawn"]
}
```
