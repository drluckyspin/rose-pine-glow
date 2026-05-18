// Verify Glamour can load and render each Rosé Pine style JSON.
package main

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/charmbracelet/glamour"
)

// moon-dark muted (6e6a86) + dim — progress output only
const dimMuted = "\033[2m\033[38;2;110;106;134m"

// moon-dark love (eb6f92) + dim
const dimLove = "\033[2m\033[38;2;235;111;146m"

const reset = "\033[0m"

func main() {
	root := filepath.Join("..", "..")
	styles := []string{
		"rose-pine.json",
		"rose-pine-moon.json",
		"rose-pine-moon-dark.json",
		"rose-pine-dawn.json",
	}
	md := "# Rosé Pine Glow\n\n**bold** `code` and [link](https://rosepinetheme.com)\n"

	for _, name := range styles {
		path := filepath.Join(root, "styles", name)
		r, err := glamour.NewTermRenderer(
			glamour.WithStylesFromJSONFile(path),
			glamour.WithWordWrap(72),
		)
		if err != nil {
			fmt.Fprintf(os.Stderr, "%s  ✖ create renderer %s: %v%s\n", dimLove, name, err, reset)
			os.Exit(1)
		}
		out, err := r.Render(md)
		if err != nil {
			fmt.Fprintf(os.Stderr, "%s  ✖ render %s: %v%s\n", dimLove, name, err, reset)
			os.Exit(1)
		}
		if len(out) < 10 {
			fmt.Fprintf(os.Stderr, "%s  ✖ %s: output too short%s\n", dimLove, name, reset)
			os.Exit(1)
		}
		fmt.Fprintf(os.Stderr, "%s  verified %s (%d bytes)%s\n", dimMuted, name, len(out), reset)
	}
}
