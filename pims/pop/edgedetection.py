#!/usr/bin/env python

import numpy as np
import scipy.ndimage as ndimage
import platform
if platform.platform().startswith('Linux'):
    from PIL import Image
    _BASEDIR = '/home/pims'
else:
    import Image
    _BASEDIR = '/Users/ken'

def fullprint(*args, **kwargs):
  from pprint import pprint
  opt = np.get_printoptions()
  np.set_printoptions(threshold='nan')
  pprint(*args, **kwargs)
  np.set_printoptions(**opt)

def demo():

    # A small "bw image" array
    data = np.array([
               [1, 0, 0, 0, 1], 
               [0, 0, 1, 0, 1], 
               [1, 0, 0, 0, 1], 
               [1, 0, 0, 0, 1], 
               [1, 0, 0, 0, 1], 
               [0, 0, 0, 0, 1], 
               [0, 0, 1, 0, 1], 
               [0, 0, 0, 0, 1], 
               [0, 0, 0, 0, 1], 
               [0, 0, 0, 0, 1], 
            ])

    # Fill holes to make sure we get nice clusters
    filled = ndimage.morphology.binary_fill_holes(data)
     
    # Now separate each group of contiguous ones into a distinct value
    # This will be an array of values from 1 - num_objects, with zeros
    # outside of any contiguous object
    objects, num_objects = ndimage.label(filled)
    
    # Show contiguous objects' labels: 1, 2, ..., n
    print 'These are the labeled objects:'
    print objects
    
    # Now return a list of slices around each object
    #  (This is effectively the tuple that you wanted)
    object_slices =  ndimage.find_objects(objects)
    
    # Just to illustrate using the object_slices
    print '\nobject slices:'
    #print object_slices
    for obj_slice in object_slices:
        print '-' * 80
        print data[obj_slice],
        print '<- ROW RANGE =',
        print obj_slice[0].start, ':',
        print obj_slice[0].stop, ',',
        print 'COL RANGE =',
        print obj_slice[1].start, ':',
        print obj_slice[1].stop        
     
    # Find the object with the largest area
    areas = [np.product([x.stop - x.start for x in slc]) for slc in object_slices]
    largest = object_slices[np.argmax(areas)]
    
    print '\nobject with largest area:'
    print data[largest]
  
demo()