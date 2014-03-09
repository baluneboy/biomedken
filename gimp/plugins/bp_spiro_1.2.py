# SpiroGraph
# Python plug-in for GIMP 2.8
# version 1.2
#
# This script is a spirograph generator, it creates symmetrical circular
# vector patterns.
#
#
#2012-Apr-27
# Andrei Roslovtsev
# www.bytes-and-pixels.com
# andrei[AT]bytes-and-pixels.com

#-----------------------------------------------------------


from gimpfu import *
import sys,random as r
import math, string

sizes = []

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
def hcfList (list):
    "Highest common factor of a list of integers"

    if len (list) == 0:
        return 1

    h = list [0]

    for i in range (1, len(list)):
        h = hcf (h, list [i])

    return h        

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
def hcf (n1, n2):
    "Highest common factor of two integers"

    n1 = abs (int (n1))
    n2 = abs (int (n2))

    while 1:
        if n1 > n2:
            t = n1
            n1 = n2
            n2 = t

        if n1 == 0:
            return n2

        if n1 == 1:
            return 1

        n2 = n2 % n1        

#Spirograph code from http://www.eddaardvark.co.uk/python_patterns/code/Spirograph.py
points_rev=[]
def draw_path(image,drawable,speed1,speed2,size1,size2,phase1,phase2,points,scale, reverse):
##    speeds     = [0, 4]   # Rotation rates
##    sizes      = [65, 50]    # Relative sizes of the wheels
##    phases     = [0, 0]    # Starting angles of the wheels
##    points     = 500       # Number of points in the pattern
##    ccl_radius = 3         # used when drawing circles for points
##    scale      = 1         # Used to rescale the entire pattern
    global sizes
    speeds     = [speed1, speed2]   # Rotation rates
    sizes = [size1, size2]    # Relative sizes of the wheels
    phases     = [phase1, phase2]    # Starting angles of the wheels
    points     = points       # Number of points in the pattern
    ccl_radius = 3         # used when drawing circles for points
    scale      = scale         # Used to rescale the entire pattern

    size       = (pdb.gimp_image_width(image),pdb.gimp_image_height(image))
    rad = min (size[0], size[1])   
    radius = (rad/2) - 2 - ccl_radius


    points = getPoints(speeds,phases,radius,scale,points,size,reverse)

    vObj = pdb.gimp_vectors_new(image, 'spiro_')
    pdb.gimp_image_add_vectors(image, vObj, 100)
    # cannot use below function as there is a bug in gimp 2.7 regarding parent
    #pdb.gimp_image_insert_vectors(image, vObj, None,0)
    stroke_id = pdb.gimp_vectors_stroke_new_from_points(vObj, 0,
							len(points),points,1)

    if reverse:
        vObj2 = pdb.gimp_vectors_new(image, 'spiro_reverse_')
        pdb.gimp_image_add_vectors(image, vObj2, 100)
        stroke_id2 = pdb.gimp_vectors_stroke_new_from_points(vObj2, 0,
                                                            len(points),points_rev,1)
    
    #pdb.gimp_vectors_stroke_close(vObj, stroke_id)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
def fixWheels (speeds,phases,radius,scale,points,size):
    """
    Fix the wheel parameters. Assumes that the speeds are definitive and
    that the phases and sizes are dependent.
    """
    global sizes
# ensure all the arrays are the same size

    l1 = len (speeds)
    l2 = len (sizes)
    l3 = len (phases)

    num_wheels = min (l1, l2, l3)

    if num_wheels < 2:
        raise "Too few wheels"

    speeds = speeds [:num_wheels]
    sizes  = sizes  [:num_wheels]
    phases = phases [:num_wheels]

    sum = 0

# calculate the total size

    for i in range (0,num_wheels):
        sum += abs (sizes [i])

# Normalise and apply scale factor

    factor = float (radius) * scale / float (sum)    

    for i in range (0,num_wheels):
        sizes [i] *= factor
    

# Fix the speeds - if there is a common factor we just draw the same
# pattern multiple times, so we divide all the speeds by their highest
# common factor

    speeds = [int (x) for x in speeds]                     
    h = hcfList (speeds) ;
    speeds = [x / h for x in speeds]

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
def getPoints (speeds,phases,radius,scale,points,size,reverse):
    """
    Returns the set of points defining the pattern
    """
    fixWheels (speeds,phases,radius,scale,points,size)

# Initialise

    dt     = [2 * math.pi * x / points for x in speeds]
    theta  = [t for t in phases]
    xc     = size [0] / 2
    yc     = size [1] / 2
    wlist  = range (0, len (speeds))
    loc_points = []

    if len (speeds) < 1:
        print "*** No wheels ***"
        return loc_points
    
# Calculate the points

    for i in range (0, int(points)):
        x = xc
        y = yc
        
        for j in wlist:
            x += sizes [j] * math.cos(theta [j])
            y += sizes [j] * math.sin(theta [j])
            theta [j] += dt [j]

        loc_points.append (x)
        loc_points.append (y)

        loc_points.append (x)
        loc_points.append (y)

        loc_points.append (x)
        loc_points.append (y)

        if reverse:
            points_rev.append (y)
            points_rev.append (x)
            points_rev.append (y)
            points_rev.append (x)
            points_rev.append (y)
            points_rev.append (x)

    points_rev.reverse()
    return loc_points        

#---------------------------------------------------------------------
register(
    "Spirograph",
    N_("Create a SpiroGraph path"),
    "Create a vector path",
    "Andrei Roslovtsev",
    "www.bytes-and-pixels.com",
    "2011",
    "_SpiroGraph",
    "RGB*, GRAY*",
    [   (PF_IMAGE, "image",       "Input image", None),
        (PF_DRAWABLE, "drawable", "Input drawable", None),
        (PF_SPINNER, "speed1", "Speed 1:", 1, (-100, 100, 0.1)),
        (PF_SPINNER, "speed2", "Speed 2:", 7, (-100, 100,0.1)),
        (PF_SPINNER, "size1", "Size 1:", 70, (1, 1000, 1)),
        (PF_SPINNER, "size2", "Size 2:", 50, (1, 1000, 1)),
        (PF_SPINNER, "phase1", "Phase 1:", 0, (0, 100, 0.1)),
        (PF_SPINNER, "phase2", "Phase 2:", 0, (0, 100, 0.1)),
        (PF_SPINNER, "points", "Points:", 500, (0, 10000, 1)),
        (PF_SPINNER, "scale", "Scale:", 0.3, (0.01, 1, 0.01)),
        (PF_TOGGLE, "reverse", "Reverse Path:", 1)
    ],
    [],
    draw_path,
    #menu="<Image>/File/Create/Buttons",
    #menu="<Image>/arplugs...",
    menu="<Image>/Filters/Bytes-and-Pixels.com",
    domain=("gimp20-python", gimp.locale_directory)
    )

main()
