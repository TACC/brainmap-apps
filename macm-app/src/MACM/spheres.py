#!/usr/bin/python3

# Required input:
#	text file with column 1,2,3 as XYZ coordinate values and column 4 (optional) is label

# import sys for getting command-line arguments
import sys

# for checking if paths exist, making directories, etc
import os
# also... for calling other (FSL) command-line tools

# reading .nii.gz images
import nibabel as nib

# holding image data
import numpy as np

# correlation between arrays
import scipy.stats

# FSL commands use file names without extensions
fileExt = ".nii.gz"

# print way too many messages
verbose = True
# use -v flag for verbose

# default to MNI mask
maskName = "masks/MNI152_wb_dil"
# use -tal to switch to Talairach mask

# default radius in millimeters
radius = 6
# use -r=<value> to change


###### --- command-line arguments --- #######

nArgs = len(sys.argv)
cmdName = sys.argv[0]
if nArgs <= 1:
    # not enough arguments
	print('Usage: '+ cmdName +' <foci text file>')
	quit(-1)

# required parameter name !
fociName = None

for param in sys.argv[1:]:
    # check all flags
    lower = param.lower()
    
    if lower == '-v' or lower == '-verbose':
        verbose = True
    elif lower.startswith('-r='):
    	radius = float( param[3:] )
    elif lower == '-tal' or lower == '-talairach':
        maskName = "masks/Tal_wb_dil"
    else:
    	fociName = param


###### --- read mask image --- ######

# complain and quit if input image series can't be read
if not os.path.exists(maskName + fileExt):
	print("\t...Mask does not exist:", maskName + fileExt)
	quit

print("\t...Reading:", maskName + fileExt)
maskNii = nib.load(maskName + fileExt)
maskData = maskNii.get_fdata()

# x,y,z values are in image-space -> use world-space to be human-readable
# split affine into 3x3 & 3x1 to get tranform for world-space coordinates
M   = maskNii.affine[:3, :3]
abc = maskNii.affine[:3, 3]

# assumption of M+abc transform: the last row must be [ 0 0 0 1 ]
row = maskNii.affine[3, :4]
if np.any( row != [0,0,0,1] ):
	print("\t...Unexpectedly complicated tranform- last row =", row)
	quit(-1)

if verbose:
	# INFO: print mask image dimension sizes
	print("\t...Image dimensions:", maskData.shape )
	
	# INFO: print non-zero voxels inside mask too
	print("\t...Non-zero voxel count:", np.count_nonzero( maskData ))
	
	# INFO: print mask image orientation (least helpful info here... move to distance?)
	print("\t...Image orientation:", nib.aff2axcodes( maskNii.affine ) )
	
	# INFO: print voxel sizes
	print("\t...Voxel sizes:", maskNii.header.get_zooms())


###### --- read foci text --- ######

if not fociName:
	print("\t...No foci text file input given")
	quit

with open(fociName, 'r') as fociFile:
	fociData = fociFile.readlines()
print("\t...Read {0} lines in {1}".format(len(fociData), fociName))


# check validity of foci lines into ROI list of tuple of (x,y,z,name)
roiData = []
for line in fociData:
	# remove newline
	line = line.rstrip()
	
	# skip over empty lines
	if len(line) < 1:
		continue
	
	# split on whitespace
	parts = line.split()
	
	if len(parts) < 3:
		print("\t...Unable to parse line:", line)
		continue
	
	if len(parts) == 3:
		name = "ROI" + (len(roiData) + 1)
	
	if len(parts) == 4:
		name = parts[3]
	
	coord = ( parts[0], parts[1], parts[2], name )
	
	roiData.append( coord )
print("\t...Read {0} ROI from {1}".format(len(roiData), fociName))


###### --- create output directory --- ######

outputDir = fociName
if outputDir.endswith('.txt') or outputDir.endswith('.tsv'):
	outputDir = outputDir[:-4]

print('\t...Creating output directory '+ outputDir)
os.makedirs(outputDir)


###### --- create ROI images --- ######

# use radius squared to compare to squared distance between coordinates
r_sq = radius * radius

for ROI in roiData:
	coord = [ float(ROI[0]), float(ROI[1]), float(ROI[2]) ]
	name = ROI[3]
	
	# create image copy of reference mask with all zero values
	roiCopy = np.array( maskData, copy=True )
	
	# for each voxel
	dims = roiCopy.shape
	for z in range(dims[2]):
		for y in range(dims[1]):
			for x in range(dims[0]):
				# get voxel's coordinate value
				voxel = [ x, y, z ]
				world = M.dot(voxel) + abc
				
				# get distance (squared) between them
				xd = (coord[0] - world[0]) * (coord[0] - world[0])
				yd = (coord[1] - world[1]) * (coord[1] - world[1])
				zd = (coord[2] - world[2]) * (coord[2] - world[2])
				d_sq = xd + yd + zd
				
				# zero out values that are too far away
				if (d_sq > r_sq):
					roiCopy[x, y, z] = 0
	
	# check how many voxels are left
	roiVoxelCount = np.count_nonzero( roiCopy )
	print('\t...Voxel count:', roiVoxelCount)
	
	# save ROI
	roiFile = os.path.join(outputDir, name + fileExt)
	print('\t...Output name:', roiFile)
	
	header = nib.Nifti1Image(roiCopy, maskNii.affine, dtype=np.uint8)
	print('\t...Created ROI header')
	
	nib.save(header, roiFile)
	print('\t...Saved {0} with {1} voxels'.format(roiFile, roiVoxelCount))

