#!/usr/bin/env python

from pims.utils.commands import timeLogRun

class PdfjamProperty(object):
    """
    This class implements property values for pdfjam commands.

    Argument is converted to float.

    PdfjamProperty can also be constructed from:

      - numeric strings similar to those accepted by the
        float constructor (for example, '-2.3')

      - float, Fraction, and Decimal instances

      - integers
      
    """

    # We're immutable, so use __new__ not __init__
    def __new__(cls, value=0):
        """Constructs a PdfjamProperty.

        Takes a string like '3/2' or '1.5', Fraction instance, an
        integer, or a float.

        Examples
        --------
        >>> PdfjamProperty( 1.3579 )
        PdfjamProperty(1.36)
        >>> PdfjamProperty( 9 )
        PdfjamProperty(9.00)
        >>> from fractions import Fraction
        >>> PdfjamProperty( Fraction(1,2) )
        PdfjamProperty(0.50)
        >>> PdfjamProperty( '-4.2' ).value
        -4.2
        
        """
        self = super(PdfjamProperty, cls).__new__(cls)

        try:
            self._value = float(value)
            return self
        except TypeError:
            raise TypeError("input value should be a float, int, "
                            "string or a Fraction instance")
        
        self._value = value
        return self
    
    @property
    def value(a):
        return a._value

    def __repr__(self):
        """repr(self)"""
        return ('PdfjamProperty(%.2f)' % (self._value))

    def __str__(self):
        """str(self)"""
        return '%.2f' % self._value

class PdfjamScale(PdfjamProperty):
    """
    This class implements property values for pdfjam scale argument.

    Takes a string like '85/100' or '0.88', Fraction instance, or
    a float (but not an int).
    
    Argument is converted to float and must satisfy 0 < value <= 1.
    
    PdfjamScale can also be constructed just like PdjjamProperty.

    Examples
    --------
    >>> PdfjamScale( 1.5 )
    Traceback (most recent call last):
    ...
    ValueError: input value must have 0 < value <=1
    >>> PdfjamScale( 9 )
    Traceback (most recent call last):
    ...
    TypeError: input value must cast to float: 0 < value <=1
    >>> from fractions import Fraction
    >>> PdfjamScale( Fraction(1,2) )
    PdfjamScale(0.50)

    """
    def __new__(cls, value=0):
        """
        Constructs a PdfjamScale property.
        """
        self = super(PdfjamScale, cls).__new__(cls)

        if isinstance(value, int):
            raise TypeError('input value must cast to float: 0 < value <=1')
        try:
            foo = float(value)
            #return self
        except TypeError:
            raise TypeError("input value should be a float, int, "
                            "string or a Fraction instance")
        
        # scale must have value between 0 and 1
        if value <= 0 or value > 1:
            raise ValueError('input value must have 0 < value <=1')
        
        self._value = value
        return self
    
    def __repr__(self):
        """repr(self)"""
        return ('PdfjamScale(%.2f)' % (self._value))

class PdfjamOffsetScale(object):
    """
    This class implements offset/scale part of arguments for pdfjam command.

    Takes args for xoffset, yoffset, and scale; where offset values are PdjjamProperty
    and scale is a PdfjamScale.

    Examples
    --------
    >>> print PdfjamOffsetScale( xoffset=-3.75 ).string
    --offset '-3.75cm 1.00cm' --scale 0.85

    """    
    def __init__(self, xoffset=-4.25, yoffset=1, scale=0.85):
        self._xoffset = PdfjamProperty( xoffset )
        self._yoffset = PdfjamProperty( yoffset )
        self._scale = PdfjamScale( scale )
   
    @property
    def xoffset(a): return a._xoffset.value
    
    @property
    def yoffset(a): return a._yoffset.value
    
    @property
    def scale(a): return a._scale.value

    @property
    def string(a):
        # pdfjam --offset '-2.75cm 0.75cm' --scale 0.88 inputFile.pdf --landscape etc.
        return "--offset '{0:0.2f}cm {1:0.2f}cm' --scale {2:0.2f}".format(a.xoffset, a.yoffset, a.scale)

class PdfjamCommand(object):
    """This class implements pdfjam commands.

    INPUTS:
    infile - required string to input PDF file
    xoffset - optional float for X-offset in cm; defaults to -3
    yoffset - optional float for Y-offset in cm; defaults to 1
    scale - optional float for 0 < scale <= 1; defaults to 0.88
    orient - optional string, either empty or '--landscape'
    
    OUTPUT:
    The PDF output file with name similar to input, but with suffix added from:
    pdfjam --offset '-2.75cm 0.75cm' --scale 0.88 infile.pdf --landscape --outfile infile_offset_-2p75_0p75_scale_0p88.pdf

    """
    def __init__(self, infile, xoffset=-3, yoffset=1, scale=0.88, orient='landscape', log=None):
        """
        A pdfjam command with appropriate arguments.
        """
        self._infile = infile
        self._xoffset = xoffset
        self._yoffset = yoffset
        self._scale = scale
        self._orient = '--' + (orient or '')
        self._offsetscalestr = PdfjamOffsetScale( xoffset=xoffset, yoffset=yoffset, scale=scale ).string
        self._log = log
        self._command = "pdfjam %s %s %s --outfile /tmp/trashout.pdf" % (self.offsetscalestr, self.infile, self.orient)
        
    def __str__(self):
        return self.command
    
    @property
    def infile(a): return a._infile

    @property
    def xoffset(a): return a._xoffset
    
    @property
    def yoffset(a): return a._yoffset

    @property
    def scale(a): return a._scale   

    @property
    def orient(a): return a._orient
    
    @property
    def offsetscalestr(a): return a._offsetscalestr

    @property
    def command(a): return a._command

    @property
    def log(a): return a._log
    
    def run(self, timeoutSec=10, log=None):
        retCode, elapsedSec = timeLogRun('echo -n "Start pdfjam cmd at "; date; %s; echo -n "End   pdfjam cmd at "; date' % self.command, timeoutSec, log=log)

def demo(f, scale=0.5, log=False):
    from pims.core.files.log import demo_log, NoLog
    if log:
        logDemo = demo_log('/tmp/trashdemo.log')
    else:
        logDemo = NoLog()
    pc = PdfjamCommand(f, scale=scale, log=logDemo)
    pc.run(log=logDemo)

if __name__ == "__main__":
    import doctest
    doctest.testmod()
    
    print 'Now for a demo...'
    demo('/tmp/1qualify_2013_10_01_00_ossbtmf_roadmap.pdf', log=False)
