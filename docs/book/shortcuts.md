# Keyboard Shortcuts

A few new terms: The shell's input field is called the *slate*; the output area above the
slate, where this doc is rendered, is called the *board*, and the text editor on the right
is just called the *editor*.

Note: The *Meta* key refers to the *Cmd* key on OS X and the *Ctrl* key on everything else.

## Slate Only Keybindings

- `Meta.Enter`: Execute the contents of the slate
- `Meta.Up`: Scroll back through your input history
- `Meta.Down`: Scroll forward through your input history

## Editor Only Keybindings

- `Meta.Enter`: Execute the editor content or selected text

## Slate and Editor Keybindings

- `Meta.S`: Set the contents of the editor to local storage
- `Meta.P`: Print the editor content or selected text as Markdown
- `Meta.Dot`: Toggle focus, between the slate and the editor
- `Meta.Esc`: Clear the board, destroying everything on it

When executing the editor content, the source will be treated as Literate CoffeeScript if
the chit key ends with `.coffee.md` or `.litcoffee`.

Beyond these keyboard shortcuts, you control everything using a little API. If you're new
to CoffeeShop, you should look at the [Builtins](/docs/book/builtins.md) doc next.
