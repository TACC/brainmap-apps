#!/usr/bin/python
# arguments: bmap dump, location dump, output directory name
# assumes bmap dump has IDs for first two columns and subjects for last column
# assumes location dump has 2 ID columns and 3 coordinate columns

import re
import sys
import os

# choose reference space to avoid warning messages later
Talairach = True
# -mni to switch to MNI space

# allow for NOT having variable FWHM based on subject size
# just in case we want to compare with & without variable FHWM
staticSubjectSize = False
# -nosubj to switch to static subject sizes

# group experiments from the same paper?
PaperLevel = False
# -paper to use

def writeSubjectHeader(bmap, path):
    # create the header format
    if Talairach:
        header = '// Reference=Talairach\n// {}\n// Subjects={}\n'
    else:
        header = '// Reference=MNI\n// {}\n// Subjects={}\n'
    
    # keep track of how many we write
    countExp = 0
    lastID = 'no_such_ID'
    minSubj = 0
    
    for line in bmap:
        # split by tabs
        col = line.split('\t')
        
        # get first, second & last fields
        paper = col[0]
        exp   = col[1]
        subj  = col[ len(col)-1 ].strip()  # beware extra new-line
        
        # subject size of 4 gives a fwhm of 12, previous ICA used FWHM=12
        if staticSubjectSize:
            subj = 4
        
        # open file using 'w' for 'write' which will overwrite any previous data
        if PaperLevel:
            name = paper +'_0'
        else:
            name = paper +'_'+ exp
        
        # new paper, reset subjects
        if name != lastID:
            minSubj = subj
        
        # only write each paper once
        if name == lastID:
            # double check min subjects
            if subj < minSubj:
                minSubj = subj
            else:
                # especially don't re-write if nSubj isn't lower
                continue
        
        fullpath = path + name + '.txt'
        f = open(fullpath, 'w')
        
        # write the header
        f.write(header.format(name, subj))
        countExp += 1
    
    print('wrote subject info to {} files'.format(countExp))

def appendFoci(loc, path):
    # keep track of the last paper_exp id
    lastID = 'no_such_ID'
    file = None
    
    # use a regular expression (re)
    # finds digits, hyphens (negative) and periods (decimal places)
    wordre = re.compile('[0-9-\.]+')

    # keep track of how many successful locations there are
    countLoc = 0
    countFile = 0
    countSkip = 0
    nothing = 0
    
    for line in locations:
        # split by tabs
        #col = line.split('\w')
        col = wordre.findall(line)
        
        if len(col) != 5:
            # usually blank lines or SQL headers
            continue
        
        # get paper & exp IDs
        paper = col[0]
        exp = col[1]
        
        # check for invalid IDs, must be all digits
        if not paper.isdigit() or not exp.isdigit():
            continue
        
        # build the file name from IDs
        if PaperLevel:
            name = paper +'_0'
        else:
            name = paper +'_'+ exp
        
        # build the foci text & file name
        loc = col[2] +'\t'+ col[3] +'\t'+ col[4] +'\n'
        
        # if this is a new experiment
        if name != lastID:
            # open file using 'a' for 'append', which won't overwrite subjects
            fullpath = path + name + '.txt'
            if not os.path.exists(fullpath):
                countSkip += 1
                #print('{} does not have a header'.format(name))
                continue # skip over this experiment's line
            file = open(fullpath, 'a')
            
            # book-keeping
            lastID = name
            countFile += 1
        
        # write the location to file
        file.write(loc)
        countLoc += 1
    
    print('wrote {} locations to {} files (skipped {} lines)'.format(countLoc, countFile, countSkip))

# open the database dump files
bmap_meta = open(sys.argv[1])
locations = open(sys.argv[2])

# get the output path for foci files
path = sys.argv[3]
if not path.endswith('/'):
    path = path + '/'

# allow setting MNI through parameters
for param in sys.argv[3:]:
    if param.lower().find("-mni") > -1:
        Talairach = False

# allow static subjects through parameters
for param in sys.argv[3:]:
    if param.lower().find("-nosubj") > -1:
        staticSubjectSize = True

# allow setting paper-level foci groups
for param in sys.argv[3:]:
    if param.lower().find("-paper") > -1:
        PaperLevel = True

# feedback
feedback = 'creating '
if PaperLevel:
    feedback += 'paper-level foci files '
else:
    feedback += 'experiment-level foci files '
if staticSubjectSize:
    feedback += 'with static subject size (FWHM=12) '
else:
    feedback += 'with variable subject sizes '
if Talairach:
    feedback += 'in Talairach space'
else:
    feedback += 'in MNI space'
print(feedback)

# write the header info to file
writeSubjectHeader(bmap_meta, path)

# add the foci after the subject header
appendFoci(locations, path)
