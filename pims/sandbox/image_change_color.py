#!/usr/bin/env python

from PIL import Image
import numpy as np

im = Image.open('/home/pims/Desktop/test.png')
im = im.convert('RGBA')

data = np.array(im)   # "data" is a height x width x 4 numpy array

print data.shape
red, green, blue, alpha = data.T # Temporarily unpack the bands for readability

#### Replace white with red... (leaves alpha values alone...)
###white_areas = (red == 255) & (green == 255) & (blue == 255)
###blue_areas = (red == 22) & (green == 52) & (blue == 100)
####blue_areas = data == [22, 52, 100, 255]
####print np.where(blue_areas)
####print blue_areas
####print blue_areas.shape
###data[..., :-1][blue_areas] = (255, 0, 0) # leave alpha alone?

# Replace white with red... (leaves alpha values alone...)
blue_areas = (red == 22) & (green == 52) & (blue == 111)
data[..., :-1][blue_areas] = (255, 0, 255)

im2 = Image.fromarray(data)
im2.show()