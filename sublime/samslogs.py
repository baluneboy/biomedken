import sublime, sublime_plugin
import os, re

#Feb 18 11:00:05 icu-f01 Cumain v1.27[247]: ICU System clock adjusted by 0 sec 5971 usec
class FoldClockCommand(sublime_plugin.TextCommand):
	def run(self, edit):
		regions = self.view.find_all('(\w+ \d{2} \d{2}:\d{2}:\d{2} icu-f01 Cumain v1.27\[\d+\]: ICU System clock adjusted by .*sec\n)+')
		if regions:
			self.view.fold(regions)

#Feb 11 11:59:14 icu-f01 rarpd[1305]: ep1: 0:60:97:94:35:53
class FoldRarpdCommand(sublime_plugin.TextCommand):
	def run(self, edit):
		regions = self.view.find_all('(\w+ \d{2} \d{2}:\d{2}:\d{2} icu-f01 rarpd\[\d+\]: ep1: 0:\d{2}:\d{2}:\d{2}:\d{2}:\d{2}\n)+')
		if regions:
			self.view.fold(regions)

#Feb 18 06:42:29 icu-f01 /netbsd: APM ioctl get power status: unknown error code (0x530a)
class FoldApmCommand(sublime_plugin.TextCommand):
	def run(self, edit):
		regions = self.view.find_all('(\w+ \d{2} \d{2}:\d{2}:\d{2} icu-f01 /netbsd: APM ioctl get power status: unknown error code \(0x530a\)\n)+')
		if regions:
			self.view.fold(regions)

class SamsLogsFold(sublime_plugin.EventListener):
	def on_load(self, view):
		files_handlers = [
			['.*/var/log/messages',         'rarpd', 'apm'],
			['.*/var/log/sams-ii/messages', 'clock'],
		]
		file_name = view.file_name()
		if file_name:
			for expr_handlers in files_handlers:
				print 'checking', expr_handlers
				pat = expr_handlers[0]
				handlers = expr_handlers[1:]
				print pat
				print handlers
				match = re.search(pat, file_name, re.IGNORECASE)
				if match:
					print file_name, 'will handle these:',
					for h in handlers:
						print h,
						mapping = 'fold_' + h
						view.run_command(mapping)
					print 'done'
				else:
					print 'NOT HANDLING', file_name