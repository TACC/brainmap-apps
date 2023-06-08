#!/usr/bin/python
# arguments: bmap dump with locations, output directory name
# assumes bmap dump has paper and experiment IDs for first two columns
# assumes bmap dump has subject and X and Y and Z as last four columns

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

# generate one file per experiment/group or one large file with many experiments
ManyFiles = True

def writeFociText(meta, path):
    # create the header format
    if Talairach:
        fileHeader = '// Reference=Talairach'
    else:
        fileHeader = '// Reference=MNI'
    groupHeader = '\n// {}\n// Subjects={}\n'
    
    # keep track of how many we write
    countExp = 0
    countLoc = 0
    countFile = 0
    
    lastID = 'no_such_ID'
    file = None
    if not ManyFiles:
        file = open(path + 'export.txt', 'w')
        file.write(fileHeader)
        countFile += 1
    
    for line in meta:
        
        # split by tabs
        col = line.split('\t')
        
        # get paper and experiment id
        paper = col[0]
        exp   = col[1]
        name = paper +'_'+ exp
        
        # check for invalid paper ID, must be all digits
        if not paper.isdigit():
            # if it doesn't look like a header, complain
            if paper.lower().find("paper") == -1:
                print('unusual paper ID: {}'.format(paper))
            continue
        
        # check for invalid experiment/group ID, must be all digits or underscores
        #if not exp.isidentifier():
        #    print('unusual experiment ID: {}', exp)
        #    continue
        # use a regular expression (re) for a-zA-Z and underscore
        # finds digits, hyphens (negative) and periods (decimal places)
        #wordre = re.compile('[0-9-\.]+')
        #col = wordre.findall(line)
        #col = line.split('\w')
        # TODO: allow only digits and underscore
        
        
        # subject size of 4 gives a fwhm of 12, previous ICA used FWHM=12
        if staticSubjectSize:
            subj = 4
        else:
            subj = col[-4]
        
        # build the foci text
        loc = col[-3] +'\t'+ col[-2] +'\t'+ col[-1].rstrip() +'\n'
        
        # new foci group!
        if name != lastID:
            
            # if many files, deal with files here
            if ManyFiles:
                if file:
                    file.close()
                
                # check if file exists
                fullpath = path + name + '.txt'
                if os.path.exists(fullpath):
                    print('{} already exists - maybe meta file needs sorting?'.format(name))
                    file = open(fullpath, 'a')
                else:
                    file = open(fullpath, 'w')
                    file.write(fileHeader)
                
                countFile += 1
            
            # add groupHeader
            file.write(groupHeader.format(name, subj))
            countExp += 1
            lastID = name
        
        # write the location to file
        file.write(loc)
        countLoc += 1
        
    print('wrote {} locations and {} groups to {} files'.format(countLoc, countExp, countFile))

# open the database dump files
bmap_meta = open(sys.argv[1])

# get the output path for foci files
path = sys.argv[2]
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
    if param.lower().find("-onefile") > -1:
        ManyFiles = False

# feedback
feedback = 'creating '
if ManyFiles:
    feedback += 'many experiment-level foci files '
else:
    feedback += 'one large dataset foci file '
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
writeFociText(bmap_meta, path)
