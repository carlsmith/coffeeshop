define ->
    
    # stacktrace - derived from stacktrace-parser...
    # github.com/errwischt/stacktrace-parser - Copyright Georg Tavonius [MIT License]
    
    (stacktrace) ->
        
        # Always returns an array of two items [Array:stack, Bool:untraceable]
        
        stack = []
        lines = stacktrace.split "\n"
        limit = "scripts/core.coffee"
        
        gecko = /^(?:\s*(\S*)(?:\((.*?)\))?@)?((?:file|http|https).*?):(\d+)(?::(\d+))?\s*$/i 
        node = /^\s*at (?:((?:\[object object\])?\S+(?: \[as \S+\])?) )?\(?(.*?):(\d+)(?::(\d+))?\)?\s*$/i
        chrome = /^\s*at (?:(?:(?:Anonymous function)?|((?:\[object object\])?\S+(?: \[as \S+\])?)) )?\(?((?:file|http|https):.*?):(\d+)(?::(\d+))?\)?\s*$/i

        for line in lines

            if parts = chrome.exec line
            
                return [stack, false] if parts[2] is limit

                element =
                    file: parts[2]
                    methodName: parts[1] or "<unknown>"
                    lineNumber: +parts[3]
                    column: (if parts[4] then +parts[4] else null)

            else if parts = node.exec line
            
                return [stack, false] if parts[2] is limit

                element =
                    file: parts[2]
                    methodName: parts[1] or "<unknown>"
                    lineNumber: +parts[3]
                    column: (if parts[4] then +parts[4] else null)

            else if parts = gecko.exec line
            
                return [stack, false] if parts[3] is limit
            
                element =
                    file: parts[3]
                    methodName: parts[1] or "<unknown>"
                    lineNumber: +parts[4]
                    column: (if parts[5] then +parts[5] else null)
    
            else continue
            stack.push element
        
        [stack, true]