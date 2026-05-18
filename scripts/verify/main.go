// Verify Glamour can load and render each Rosé Pine style JSON.
package main

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/charmbracelet/glamour"
)

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
			fmt.Fprintf(os.Stderr, "FAIL %s: create renderer: %v\n", name, err)
			os.Exit(1)
		}
		out, err := r.Render(md)
		if err != nil {
			fmt.Fprintf(os.Stderr, "FAIL %s: render: %v\n", name, err)
			os.Exit(1)
		}
		if len(out) < 10 {
			fmt.Fprintf(os.Stderr, "FAIL %s: output too short\n", name)
			os.Exit(1)
		}
		fmt.Printf("OK %s (%d bytes)\n", name, len(out))
	}
}
