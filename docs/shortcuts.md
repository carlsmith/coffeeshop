# Keyboard Shortcuts

There are three main components to the user interface. The input area is
called the *slate*. The output area, above the slate, is called the *board*.
The text editor on the right is just called the *editor*.

Note: The <kbd>Meta</kbd> key refers to <kbd>Cmd</kbd> on OS X and
<kbd>Ctrl</kbd> on everything else.

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

When executing the editor content, the source will be treated as Literate
CoffeeScript if the chit key ends with `.coffee.md` or `.litcoffee`.

Beyond these keyboard shortcuts, you control everything using a little API. If
you are new to CoffeeShop, you should look at the [Builtins](/docs/builtins.md)
doc next.
