#!/usr/bin/python

# TODO
# - decide where source code for Windows TReK will reside (on yoda)
#   '/misc/yoda/www/plots/user/sams/trekscripts'
# - keep Windows TReK source code in svn on jimmy via incrontab entry
# ------
# - capture multiple, relevant windows
# - embed link to these screenshots in the eetemp.html code
# - crop messages part of Accelerometer View to avoid showing sensitive info
# - get this as scheduled task on TReK (every minute)
#
# Get coords for original win loc
# Move win to "home" loc; i.e. the (0,0) location
# Grab image of win
# Move win back to original loc

from PIL import Image, ImageOps
#from PIL import ImageGrab
#import win32gui
#
#def grab_image():
#    toplist, winlist = [], []
#    def enum_cb(hwnd, results):
#        winlist.append((hwnd, win32gui.GetWindowText(hwnd)))
#    win32gui.EnumWindows(enum_cb, toplist)
#    
#    # Robust try/except here with STALE annotation on previous screenshot via PIL
#    accel_view = [(hwnd, title) for hwnd, title in winlist if title.startswith('Accelerometer View')]
#    
#    # Just grab the hwnd for first window matching window title pattern
#    accel_view = accel_view[0]
#    hwnd = accel_view[0]
#    
#    win32gui.SetForegroundWindow(hwnd)
#    bbox = win32gui.GetWindowRect(hwnd)
#    img = ImageGrab.grab(bbox)
#    
#    # Save to yoda
#    img.save(r'//yoda/pims/www/plots/user/sams/trash.bmp')
#    #img.show()

# use PIL to crop off Messages (in case of IP addresses or such)
def crop_acc_view_msgbox(imfile):
    """use PIL to crop off Messages (in case of IP addresses or such)"""
    im = Image.open(imfile)
    imfile_cropped = imfile.replace('.bmp', "_cropped.jpg")
    w, h = im.size
    im.crop((0, 0, w, h-160)).save( imfile_cropped, "JPEG" )
    return imfile_cropped

def create_crappy_thumbnail(imfile):    
    im = Image.open(imfile)
    imfile_thumb = imfile.replace('.jpg', "_thumb.jpg")
    w, h = im.size
    im.crop((0, 0, 256, 256)).save( imfile_thumb, "JPEG" )
    return imfile_thumb

if __name__ == "__main__":
    
    imfile = '/misc/yoda/www/plots/user/sams/screenshots/acc_view.bmp'
    
    imfile_cropped = crop_acc_view_msgbox(imfile)
    print 'wrote %s' % imfile_cropped
    
    imfile_thumb = create_crappy_thumbnail(imfile_cropped)
    print 'wrote %s' % imfile_thumb