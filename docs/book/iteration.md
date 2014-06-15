# Iteration

Iteration in JavaScript has archaic syntax, reminiscent of C. ES5 introduced the `forEach` function, which is prettier, but requires a function call on every iteration, so it's generally much slower. CoffeeScript uses modern `for`/`in` based iterators.

    for name in ["Roger", "Roderick", "Brian"]
      alert "Release #{name}"

You can also grab the index by providing an extra name to assign to (in practice, everyone uses `i`).

    for name, i in ["Roger", "Roderick", "Brian"]
      alert "Position: #{i} - Name: #{name}"

You can also write oneliners, using the postfix form.

    release prisoner for prisoner in ["Roger", "Roderick", "Brian"]

As with Python comprehensions, you can filter too.

    release prisoner for prisoner in prisoners when prisoner[0] is "R"

You can also use comprehensions for iterating over properties in objects; instead of the `in` keyword, use `of`.

    names = sam: seaborn, donna: moss
    alert("#{first} #{last}") for first, last of names

CoffeeScript exposes one low-level loop, the `while` loop. This works like it does in JavaScript, but better: It returns an array of the results (like JavaScripts `Array.prototype.map` function).

    num = 6
    minstrel = while num -= 1
      num + " Brave Sir Robin ran away"

---

Next Page: [Slicing](/docs/book/slicing.md)