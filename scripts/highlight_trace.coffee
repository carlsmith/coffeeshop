define ->

    (source, lineNumber, charNumber) ->

        escape = (line) -> line.escapeHTML().split(' ').join "&nbsp;"

        lines = source.lines()
        line  = lines[lineNumber]

        start = escape line.slice 0, charNumber
        end   = escape line.slice charNumber + 1

        char = line[charNumber]
        look = if char then "bold" else "error_missing_char"
        char = if char then escape char else "&nbsp;"

        lines[lineNumber] = "#{start}<span class=#{look}>#{char}</span>#{end}"

        for line, index in lines
            if index isnt lineNumber then lines[index] = escape line

        jQuery("<span class=error>").html lines.join "<br>"
