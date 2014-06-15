# Keyboard Shortcuts

A few new terms: The shell's input field is called the *slate*; the output area above the slate, where this doc is rendered, is called the *board*, and the text editor on the right is just called the *editor*.

Note: The *Meta* key refers to the *Cmd* key on OS X and the *Ctrl* key on everything else.

## Slate Keybindings

- `Meta.Enter`: Execute the contents of the slate
- `Meta.Up`: Scroll back through your input history
- `Meta.Down`: Scroll forward through your input history
- `Meta.Esc`: Clear the board, destroying everything on it
- `Meta.Dot`: Focus the editor

## Editor Keybindings

- `Meta.Enter`: Execute the contents of the editor
- `Meta.S`: Save the file
- `Meta.Dot`: Focus the slate

Note: When executing the contents of the editor, if some source is selected, only that source will be executed.

Beyond these keyboard shortcuts, you control everything using a little API. If you're new to CoffeeShop, you should look at the [Builtins](/docs/book/builtins.md) doc next.