#!/usr/bin/env python

import wx
import os

# A simple multi-choice dialog
class MultiChoiceDialog(object):
    """ A simple multi-choice dialog. """
    
    def __init__(self, title, prompt, choice_list):
        
        # set choice list
        self.choice_list = self.set_choice_list(choice_list)
        
        # need to create app first
        self.app = wx.PySimpleApp()
        
        # now multichoice dialog
        self.dialog = wx.MultiChoiceDialog( None, prompt, title, self.choice_list )       
    
    def set_choice_list(self, choice_list):
        return choice_list
    
    def get_choices(self):
        
        # pre-select all items
        self.dialog.SetSelections(range(len(self.choice_list)))
        
        # interact with user
        if (self.dialog.ShowModal() == wx.ID_OK):
            selections = self.dialog.GetSelections()
            choices = [self.choice_list[x] for x in selections]
            
        self.dialog.Destroy()
        self.app.MainLoop()
        
        # return items the user selected
        return choices        
    
# A simple multi-choice dialog for files (with paths)
class MultiChoiceFileDialog(MultiChoiceDialog):
    """ A simple multi-choice dialog for files (with paths). """

    def __init__(self,title, prompt, choice_list):
        super(MultiChoiceFileDialog, self).__init__(title, prompt, choice_list)
        self.dirnames = [os.path.dirname(f) for f in choice_list]

    def set_choice_list(self, choice_list):
        return [os.path.basename(f) for f in choice_list]

    def get_choices(self):
        basenames = super(MultiChoiceFileDialog, self).get_choices()
        return [ os.path.join(d,b) for d,b in zip(self.dirnames, basenames)]

if __name__ == '__main__':
    
    #title = "Demo wx.MultiChoiceDialog"
    #prompt = "Pick from\nthis list:"
    #choice_list = [ 'apple', 'pear', 'banana', 'coconut', 'orange', 'grape', 'pineapple',
    #        'blueberry', 'raspberry', 'blackberry', 'snozzleberry',
    #        'etc' ]    
    #
    #mcd = MultiChoiceDialog(title, prompt, choice_list)
    #choices = mcd.get_choices()
    
    title = "Demo Class MultiChoiceFileDialog"
    prompt = "Pick from\nthis file list:"
    choice_list = [ '/tmp/one.txt', '/path/two.csv' ]    
    
    mcd = MultiChoiceFileDialog(title, prompt, choice_list)
    choices = mcd.get_choices()    
    
    print choices