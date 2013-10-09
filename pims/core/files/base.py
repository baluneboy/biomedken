import os

class PimsFileDoesNotExist(Exception): pass
class UnrecognizedPimsFile(Exception): pass

class File(object):
    """
    A generic representation of a PIMS file.
    """
    def __init__(self, name, show_warnings=False):
        self.name = name
        self._exists = None
        self._size = None
        if not self.exists():
            raise PimsFileDoesNotExist('caught IOError for file "%s", does it exist?' % self.name)

    def exists(self):
        try:
            with open(self.name):
                pass
            self._exists = True
        except IOError:
            self._exists = False
        return self._exists

    def __str__(self):
        return '%s object for PIMS file "%s"' % (self.__class__.__name__, self.name)

    def __repr__(self):
        return "<%s: %s>" % (self.__class__.__name__, self or "None")

    def __len__(self):
        return self.size

    def _get_size(self):
        if self.exists():
            self._size = os.path.getsize(self.name)
        else:
            raise AttributeError('Unable to determine the file size for "%s".' % self.name)
        return self._size

    def _set_size(self, size):
        self._size = size

    size = property(_get_size, _set_size)

    def asDict(self):
        return {
            'file': self.name,
            'size': self.size,            
            }

class RecognizedFile(File):
    """
    A generic representation of a recognized PIMS file.
    """
    def __init__(self, name, pattern, show_warnings=False):
        super(RecognizedFile, self).__init__(name, show_warnings=show_warnings)
        self.pattern = pattern
        self.recognized = None
        self._type = None
        self._why = None
        if not self.is_recognized(): raise UnrecognizedPimsFile('"%s"' % self.name)

    def __str__(self):
        return '%s object for recognized PIMS file "%s" because %s' % (self.__class__.__name__, self.name, self.why() )
    
    def why(self):
        raise NotImplementedError('requires a derived class to override this method')
    
    def type(self):
        raise NotImplementedError('requires a derived class to override this method')

    def is_recognized(self):
        raise NotImplementedError('requires a derived class to override this method')

class StupidRecognizedFile(RecognizedFile):
    """
    A PIMS file that is recognized because the filename contains 'stupid'.
    """
    def __init__(self, name, pattern='.*stupid.*', show_warnings=False):
        super(StupidRecognizedFile, self).__init__(name, pattern, show_warnings=show_warnings)
    
    def why(self):
        if not self._why:
            self._why = 'it contains the string "stupid"'
        return self._why

    def type(self):
        if not self._type:
            self._type = 'a_stupid_but_still_recognized_file'
        return self._type
    
    def is_recognized(self):
        if "stupid" in self.name:
            self.recognized = True
            self._type = self.type()
        else:
            self.recognized = False
        return self.recognized
