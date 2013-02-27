import os, re
import sublime, sublime_plugin

PATTERNS_TO_FOLD = [
# Feb 18 11:00:05 icu-f01 Cumain v1.27[247]: ICU System clock adjusted by 0 sec 5971 usec
'(\w+\s+\d{1,2} \d{2}:\d{2}:\d{2} icu-f01 Cumain v1.27\[\d+\]: ICU System clock adjusted by .*sec\n)+',
# Feb 11 11:59:14 icu-f01 rarpd[1305]: ep1: 0:60:97:94:35:53
'(\w+\s+\d{1,2} \d{2}:\d{2}:\d{2} icu-f01 rarpd\[\d+\]: ep1: 0:\d{2}:\d{2}:\d{2}:\d{2}:\d{2}\n)+',
# Feb 18 06:42:29 icu-f01 /netbsd: APM ioctl get power status: unknown error code (0x530a)
'(\w+\s+\d{1,2} \d{2}:\d{2}:\d{2} icu-f01 /netbsd: APM ioctl get power status: unknown error code \(0x530a\)\n)+',
# Feb 25 09:59:59 icu-f01 newsyslog[29283]: logfile turned over
'(\w+\s+\d{1,2} \d{2}:\d{2}:\d{2} icu-f01 newsyslog\[\d+\]: logfile turned over\n)+',
]

FILES_TO_FOLD = [
'.*/var/log/messages',
'.*/var/log/sams-ii/messages',
'.*/var/log/sams-ii/watchdoglog',
]

class FoldCommand(sublime_plugin.TextCommand):

    def run(self, edit):
        for pattern in PATTERNS_TO_FOLD:
            #regions = sorted(self.view.find_all(self.pattern), key=lambda x: x.begin(), reverse=True)
            #regions = self.view.find_all(pattern)
            #if regions:                
            #    for region in regions:
            #        content = self.view.substr(region) + '\n' # in effect, we want to not fold the last...
            #        self.view.replace(edit, region, content)  # ...newline char, so cheat by adding one!
            regions = self.view.find_all(pattern)
            if regions:
                self.view.fold(regions)

class InsertNoteCommand(sublime_plugin.TextCommand):
    def run(self, edit, msg='No note inserted.\n'):
        self.view.insert(edit, 0, msg)

class SamsLogsFold(sublime_plugin.EventListener):
    def on_load(self, view):
        file_name = view.file_name()
        if file_name:
            #msg = ['KH NOTE: [']
            for file_pattern in FILES_TO_FOLD:
                match = re.search(file_pattern, file_name, re.IGNORECASE)
                if match:
                    view.run_command('fold')
                    break