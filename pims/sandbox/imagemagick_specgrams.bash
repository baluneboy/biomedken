#!/usr/bin/env bash

# FIXME instead of hard code, add smarts on how to get proper geometry, scaling, and offset
# FIXME add inset at top center for identifying sensor (rate/location?)

# e.g. http://pims.grc.nasa.gov/plots/sams/121f08/121f08.jpg

# output directory
OUTDIR=/tmp

# define input image file, temp files, and composite output file
IMFILE=${1}
BNAME=`basename ${IMFILE}`
BOTRTFILE=${OUTDIR}/${BNAME/.jpg/_botright.jpg}
BORDERFILE=${BOTRTFILE/_botright.jpg/_botright_border.jpg}
COMPOSITEFILE=${BOTRTFILE/_botright.jpg/_composite.jpg}

# crop bottom right to new image
convert ${IMFILE} -crop 145x140+1500+810  -resize 175% ${BOTRTFILE}

# add border around bot right image
convert -bordercolor Black -border 10x10 ${BOTRTFILE} ${BORDERFILE}

# create composite image
convert -page 1645x900 ${IMFILE} -page +1450+760 ${BORDERFILE} -background dodgerblue -layers flatten ${COMPOSITEFILE}

# remove temp image files
rm ${BOTRTFILE} ${BORDERFILE}