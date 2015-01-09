#!/usr/bin/env python

import Image
import numpy as np
import scipy.ndimage as ndimage

def fullprint(*args, **kwargs):
  from pprint import pprint
  opt = np.get_printoptions()
  np.set_printoptions(threshold='nan')
  pprint(*args, **kwargs)
  np.set_printoptions(**opt)

def change_color_keep_transparency(rgb1, rgb2):
    #im = Image.open('/home/pims/Desktop/test.png')
    im = Image.open('/Users/ken/dev/programs/python/pims/sandbox/data/original_image.png')
    im = im.convert('RGBA')
    data = np.array(im)
    
    r1, g1, b1 = rgb1[0], rgb1[1], rgb1[2]
    r2, g2, b2 = rgb2[0], rgb2[1], rgb2[2]
    
    # FIXME there might be an index trick that preserves alpha
    # data[..., :-1][mask] = (r2, g2, b2) # this does not work!?
    
    red, green, blue, alpha = data[:,:,0], data[:,:,1], data[:,:,2], data[:,:,3]
    mask = (red == r1) & (green == g1) & (blue == b1) & (alpha >= 0)
    data[:,:,:3][mask] = [r2, g2, b2]
    #fullprint( data[ np.where(mask) ] )
    
    im2 = Image.fromarray(data)
    im2.save('/tmp/fig1_modified.png')
    im2.show()

def demo():
 
    # The array you gave above
    data = np.array([
               [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0], 
               [0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0], 
               [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
               [0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
               [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
               [0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], 
               [0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0], 
               [0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0], 
               [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0], 
               [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], 
            ])

    # A smaller array
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
    print '\nlabeled objects:'
    print objects
    
    # Now return a list of slices around each object
    #  (This is effectively the tuple that you wanted)
    object_slices =  ndimage.find_objects(objects)
    
    # Just to illustrate using the object_slices
    print '\nobject slices:'
    print object_slices
    for obj_slice in object_slices:
        print obj_slice
        print data[obj_slice]    
     
    # Find the object with the largest area
    areas = [np.product([x.stop - x.start for x in slc]) for slc in object_slices]
    largest = object_slices[np.argmax(areas)]
    
    print '\nobject with largest area:'
    print data[largest]
        
def demo2():
  rgb1 = ( 22,  52, 100) # Original "dark-blue-is-blank" value
  rgb2 = (  0,   0,   0) # Replacement color is black
  
  rgb1 = (255, 255, 255) # WHITE
  rgb2 = (255,   0,   0) # RED
  
  change_color_keep_transparency(rgb1, rgb2)
  
demo()