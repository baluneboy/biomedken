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

    It takes 5 arguments as follows: infile, xoffset, yoffset, scale,
    and orient to hopefully give a command like this:
    pdfjam --offset '-2.75cm 0.75cm' --scale 0.88 infile.pdf --landscape --outfile infile_offset_-2p75_0p75_scale_0p88.pdf

    """
    def __init__(self, infile, xoffset=-3, yoffset=1, scale=0.88, orient='--landscape'):
        """
        A pdfjam command with appropriate arguments.
        """
        self.infile = infile
        self.xoffset = xoffset
        self.yoffset = yoffset
        self.scale = scale
        self.orient = orient
        self.offsetscalestr = PdfjamOffsetScale( xoffset=xoffset, yoffset=yoffset, scale=scale ).string
        self.cmdstr = "pdfjam %s %s --landscape --outfile /tmp/trashout.pdf" % (self.offsetscalestr, self.infile)
        
    def run(self, timeoutSec=10):
        retCode, elapsedSec = timeLogRun('echo start pdfjam; date; %s; echo done' % self.cmdstr, timeoutSec, log=None)

#pc = PdfjamCommand('/tmp/1qualify_2013_10_01_00_ossbtmf_roadmap.pdf', scale=0.2)
#print pc.cmdstr
#pc.run()
#raise SystemExit

if __name__ == "__main__":
    import doctest
    doctest.testmod()
