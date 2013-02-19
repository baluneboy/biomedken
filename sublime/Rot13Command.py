import sublime, sublime_plugin

class Rot13Command(sublime_plugin.TextCommand):
    def run(self, edit):  
        sels = self.view.sel()
        for sel in sels:  
            if not sel.empty():
                # Get the selected text  
                s = self.view.substr(sel)  
                # Transform it via rot13  
                s = s.encode('rot13')  
                # Replace the selection with transformed text  
                self.replace(sel, s)
            else:
            	print 'empty sel'           

    def replace(self, edit, thread, braces, offset):
        sel = thread.sel
        original = thread.original
        result = thread.result

        # Here we adjust each selection for any text we have already inserted
        if offset:
            sel = sublime.Region(sel.begin() + offset,
                sel.end() + offset)

        result = self.normalize_line_endings(result)
        (prefix, main, suffix) = self.fix_whitespace(original, result, sel,
            braces)
        self.view.replace(edit, sel, prefix + main + suffix)

        # We add the end of the new text to the selection
        end_point = sel.begin() + len(prefix) + len(main)
        self.view.sel().add(sublime.Region(end_point, end_point))

        return offset + len(prefix + main + suffix) - len(original)             