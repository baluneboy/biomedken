import sublime, sublime_plugin
import datetime

class ExampleCommand(sublime_plugin.TextCommand):
	def run(self, edit):
		#self.view.insert(edit, 0, "Hello, World!")
		print datetime.datetime.now()

class StupidCommand(sublime_plugin.TextCommand):
	def run(self, edit):
		#self.view.insert(edit, 0, "Hello, World!")
		print 'this is stupid'