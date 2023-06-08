#!/usr/bin/python3

# Required parameter:
#    4d image series input file name prefix
#
# Optional additional parameters:
#    3d images to search with MACM
#
# Expected to exist: (but technically optional)
#    _order.txt file with names/ids for each volume in image series
#
# Outputs for 4d image:
#    _count 3d image of how many non-zero values are in each voxel
#    _index 3d image to document 3d voxel -> 1d voxel index lookup
#    _vox1D/ directory of 1D voxel images         (created for both MACM & CBP)
#    _voxCC/ directory of 3D voxel correlation images    (created for CBP only)
#
# Outputs for 3d images:
#    _cc.txt file with ROI voxels rows x image voxels columns        (if CBP)
#    _xyz.txt file with ROI voxel rows of x,y,z coordinate values    (if CBP)
#    _work.xml file with BrainMap IDs of papers in ROI               (if MACM)
#    _macm.txt file of GingerALE foci coordinates for papers in ROI  (if MACM)

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
verbose = False
# can use -v flag for verbose

# debugging images using FSL commands as reference
referenceFSL = False

# save voxelwise array / image
# useful with "foci images" and MACM
MACM = False
flagMACM = '-1d'
dbName = 'functional'

# save voxelwise correlations to every other voxel
# useful with blurred MA images and CBP
CBP = False
flagCBP = '-cc'

###### --- command-line arguments --- #######
nArgs = len(sys.argv)
cmdName = sys.argv[0]
if nArgs <= 1:
    # not enough arguments
	print('Usage: '+ cmdName +' <4D image prefix>')
	quit(-1)

# required 1st parameter: 4d image name prefix
# used to build all sorts of file names
imagePrefix = None

# optional additional parameters: ROI image search
inputNames = []
voxStart = -1; voxEnd = -1

for param in sys.argv[1:]:
    # check all flags
    lower = param.lower()
    
    if lower == flagMACM:
        MACM = True
        
    elif lower == flagCBP:
        CBP = True
        
    elif lower.startswith('-start='):
        # try reading a value after '-start='
        try:
            argVox = param[7:]
            voxStart = int(argVox)
        except ValueError:
            print("Unable to parse flag", param)
        
    elif lower.startswith('-end='):
        # try reading a value after '-end='
        try:
            argVox = param[5:]
            voxEnd = int(argVox)
        except ValueError:
            print("Unable to parse flag", param)
        
    elif lower == '-v' or lower == '-verbose':
        verbose = True
        
    elif lower.startswith('-func'):
        dbName = 'functional'
    elif lower == '-vbm':
        dbName = 'vbm'
    elif lower == '-vbp':
        dbName = 'vbp'
        
    elif imagePrefix == None:
        # if image prefix isn't set yet, this is it.
        imagePrefix = param
        
    else:
        # if not a flag, and not 4d prefix, then it must be an input ROI file
        inputNames.append(param)

# remove extension if necessary
if imagePrefix.endswith(fileExt):
    imagePrefix = imagePrefix[0:-len(fileExt)]
    if verbose:
        print("\t...Setting input file name prefix to "+imagePrefix)

###### --- global variables --- #######

# NIfTI header / 3d image / volume / shape / dims / affine / etc
nii = None

# series data and ID
imgSeries = np.zeros(0)
idSeries = []

# index data
imgIndex = np.zeros(0)
vTable = []

# Booleans for where to look in vTable, set by 3d ROI images
vMask = []

# output names for voxel images (in either the MACM or CBP directories)
vNames = []

###### --- load original image series  --- #######
# sets 4D imgSeries, nii (3D) & idSeries (with filler names)
# load required 4D image series file so we can use it to generate new images
def loadSeriesImage(prefix):
    
    global nii
    global imgSeries
    global idSeries
    
    # check if data is already loaded
    if imgSeries.size > 0:
        return
    
    # complain and quit if input image series can't be read
    file = prefix + fileExt
    if not os.path.exists(file):
        print("\t...File does not exist:", file)
        return
    
    print("\t...Reading:", file)
    niiSeries = nib.load(file)
    imgSeries = niiSeries.get_fdata()
    
    # get "time" dimension - number of 3D images in series
    nSeries = niiSeries.shape[3]
    
    # get single volume example image header to work with when saving volumes
    nii = nib.funcs.four_to_three(niiSeries)[0]
    
    if verbose:
        dims = nii.shape[0:3]
        print("\t...Found {0} volumes with dimensions".format(nSeries), dims)
        print("\t...Image orientation:", nib.aff2axcodes(nii.affine))
    
    # complain and quit if image series has zero or only one volume
    if nSeries < 2:
        print("\t...Image series must have multiple volumes")
        quit(-1)
    
    # generate filler idSeries here
    genericID = 'Image {0} of {1}'
    idSeries = [ genericID.format( s+1, nSeries ) for s in range(nSeries) ]
    
    return

def loadSeriesNames(prefix):
    
    global idSeries
    
    print("\nChecking series order:")
    
    fOrder = imagePrefix + '_order.txt'
    if not os.path.exists(fOrder):
        print("\t...Order file does not exist:", fOrder)
        return
    
    with open(fOrder, 'r') as orderFile:
        idSeries = orderFile.readlines()
    print("\t...Read {0} lines in {1}".format(len(idSeries),fOrder))
    
    # if series is loaded, compare values
    if imgSeries.size != 0:
        #nSeries = len( idSeries )
        nSeries = imgSeries.shape[3]
        
        # if both are valid, compare sizes before and after
        if nSeries != len(idSeries):
            print("\t...Sizes are not equal", nSeries, idSeries)
            quit(-1)
    
    # remove newlines from names
    idSeries = [ name.rstrip() for name in idSeries ]

# generate index image from 4D image series
def createIndexImage(prefix):
    
    # method will set these global variables
    global imgSeries
    global imgIndex
    global nii
    
    print("\nCreating index image:")
    
    # first we need the original 4d image series
    loadSeriesImage(prefix)
    
    # get count values from series using count_nonzero
    print("\t...Creating new count image")
    imgCount = np.zeros(nii.shape)
    for z in range(imgCount.shape[2]):
        for y in range(imgCount.shape[1]):
            for x in range(imgCount.shape[0]):
                vSlice = imgSeries[x,y,z]
                imgCount[x,y,z] = np.count_nonzero(vSlice)
    
    # save count data to file
    fileC = imagePrefix +"_count"+ fileExt
    nib.save(nib.Nifti1Image(imgCount, nii.affine, dtype=np.uint32), fileC)
    print('\t...Saved count image')
    
    # create index image from count image and fslmaths -index
    print("\t...Creating image with os.system call to fslmaths -index")
    os.system('fslmaths {0}_count -index {0}_index'.format(imagePrefix))
    
    print("\t...Reading index image")
    fileI = imagePrefix +"_index"+ fileExt
    niiIndex = nib.load(fileI)
    imgIndex = niiIndex.get_fdata()
    
    # ensure index image shape matches the shape we have
    if (nii.shape != imgIndex.shape):
        print("\t...Dimensions do not match:", nii.shape, niiIndex.shape)
        return False
    
    # count how often voxel index is non-zero
    tally = 0
    # ensure index image can be used as a mask too
    valOutsideMask = -1
    # keep track of if we need to save it
    adjusted = False
    for z in range(imgCount.shape[2]):
        for y in range(imgCount.shape[1]):
            for x in range(imgCount.shape[0]):
                
                # tally up how many voxels in count image are non-zero
                if round( imgCount[x,y,z] ) != 0:
                    tally += 1
                    continue
                
                # count must be zero here.  check index value too.
                val = imgIndex[x,y,z]
                
                # NaN = not a number, can be used to mean 'outside of mask'
                if np.isnan(val):
                    continue
                
                # don't round until after checking for NaN.  can't round NaN.
                i = round( val )
                
                # -1 can also be used for out-ot-mask (since NaN is weird)
                if (i == -1):
                    continue
                
                # fslmaths -index uses 0 when outside the mask
                # which can not be distinguished from index = 0
                # change out-of-mask value so we can use index as mask
                if i == 0:
                    imgIndex[x,y,z] = valOutsideMask
                    adjusted = True
                    continue
                
                # this shouldn't happen.
                print("\t...Unexpected index value where count=0:", i, x,y,z)
                imgIndex[x,y,z] = valOutsideMask
                adjusted = True
                continue
    
    # did the index image have a unique value at each voxel?
    nVox = np.count_nonzero(imgCount)
    if tally != nVox:
        # each indiviudal voxel index collision was already printed above
        print("\t...Unexpected index count != nonzero count:", tally, nVox)
        return False
    
    # re-save image to file if it was adjusted
    if adjusted:
         nib.save(nib.Nifti1Image(imgIndex, nii.affine, dtype=np.uint32), fileI)
         print('\t...Re-Saved index image (mask with != -1)')
    
    return True

# convert index from 3d image to a 1d lookup table: vTable
def createIndexTable(image):
    
    # TODO: use foci/filename tuple to combine vTable + vNames ??
    # then we can loop over vTable directly instead of range(nVox)
    # or put index value into vTable, use index when referening other tables
    
    # index max value is one less than nVoxels
    nVox = round( np.max(image) ) + 1
    print("\t...Generating index lookup table for {0} voxels".format(nVox))
    
    initFoci = [-1, -1, -1]
    lookup = [ initFoci for i in range(nVox) ]
    tally = 0
    
    # loop across 3 dimensions
    for z in range(image.shape[2]):
        for y in range(image.shape[1]):
            for x in range(image.shape[0]):
                
                # get value from index image at this foci
                val = image[x,y,z]
                
                # check for NaN - not a number.  you can't round( NaN ).
                if np.isnan( val ):
                    continue
                
                # round to integer because it's an index
                i = round( val )
                
                # index = -1 can be used instead of NaN
                if i == -1:
                    continue
                
                # create a tuple for this voxel
                foci = [ x, y, z ]
                
                # it must be an index between 0 and nVoxels (or -1)
                if i < -1 or i >= nVox:
                    # this shouldn't happen.
                    print("\t...Bad index value:", i, foci)
                    continue
                
                # before setting lookup table, check for collisions
                if lookup[i] != initFoci:
                    # this voxel should be at its initialized value, but isn't!
                    print("\t...Resetting Foci:", i, foci, lookup[i])
                else:
                    # index is valid and unique.
                    tally += 1
                
                # set it in the lookup table
                lookup[i] = foci
    
    # did the index image have a unique value at each voxel?
    if tally != nVox:
        # each indiviudal voxel index collision was already printed above
        print("\t...Unexpected index count != nonzero count:", tally, nVox)
        # fundamental error.  stop now.
        quit(-1)
    if verbose:
        print("\t...Index image values are unique and valid")
    
    return lookup

# create output file names for voxel images
def createIndexNames():
    
    global vNames
    
    if verbose:
        print("\t...Generating voxel file output names")
    
    # double-check index and x,y,z locations by making each voxel's output name
    nVox = len(vTable)
    vNames = ['' for val in range(nVox)]
    nameFormat = '{0}_{1},{2},{3}'
    
    # left-padded with zeros so file name sort will work in index order
    nDigits = len( str( nVox ))
    #if verbose: # TOO verbose.
    #    print("\t...{0} voxels = {1} digits of zfill".format(nVox, nDigits))
    
    # x,y,z values are in image-space -> use world-space to be human-readable
    # split affine into 3x3 & 3x1 to get tranform for world-space coordinates
    M   = nii.affine[:3, :3]
    abc = nii.affine[:3, 3]
    
    # assumption of M+abc transform: the last row must be [ 0 0 0 1 ]
    row = nii.affine[3, :4]
    if np.any( row != [0,0,0,1] ):
        print("\t...Unexpectedly complicated tranform- last row =", row)
        quit(-1)
    
    for i in range(nVox):
        # apply left-padding with zeros
        iz = str(i).zfill(nDigits)
        
        # tranform XYZ from image-space to world-space
        foci = vTable[i]
        world = M.dot(foci) + abc
        wx = round( world[0] )
        wy = round( world[1] )
        wz = round( world[2] )
        # assumes that world coordinates have integer values (fair assumption)
        
        # get combined output name for this voxel
        vNames[i] = nameFormat.format(iz, wx, wy, wz)

# remember which voxels in vTable are relevant to this run, right now.
def setVoxelMask(start, end, names):
    
    nVox = len(vTable)
    if nVox <= 0:
        print("Voxel table not loaded.  What's up?")
        return None
    
    # check for -start= and -end=
    if start != -1 or end != -1:
        print("\nSetting mask from index start/end:")
        if verbose:
            print("\t...Voxel start is", start)
        if start < 0 or start >= nVox:
            print("\t...Voxel is outside range", nVox, start)
        if verbose:
            print("\t...Voxel end is", end)
        if end < 0 or end >= nVox:
            print("\t...Voxel is outside range", nVox, end)
        if len( names ) > 0:
            print("\t...ROI images don't work with -start and -end")
        
        return [ v >= start and v <= end for v in range(nVox) ]
    # done with start/end
    
    # check if no ROIs - then it's all voxels
    if len( names ) == 0:
        if verbose:
            print("\nSetting mask to all because no ROI.")
        return [ True for v in range( nVox ) ]
    
    # otherwise, initialize to False and set True only inside each ROI
    print("\nSetting mask from ROI:")
    mask = [ False for v in range( nVox ) ]
    for fName in names:
        if not fName.endswith(fileExt):
            fName += fileExt
        
        if not os.path.exists(fName):
            print("\t...File does not exist:", fName)
            continue
        
        print("\t...Reading:", fName)
        niiROI = nib.load(fName)
        imgROI = niiROI.get_fdata()
        
        # ensure index image shape matches the shape we have
        if np.any(nii.shape[0:3] != imgROI.shape[0:3]):
            print("\t...Dimensions do not match:", nii.shape, imgROI.shape)
            continue
        if np.any(nii.affine != niiROI.affine):
            print("\t...Orientations do not match:", nii.affine, niiROI.affine)
            continue
        
        for v in range(nVox):
            # get input image value at this foci
            xyz = vTable[v]
            val = imgROI[ xyz[0], xyz[1], xyz[2] ]
            if (val != 0):
                mask[v] = True
    
    print("\t...Mask has {0} voxels".format( np.count_nonzero( mask ) ))
    return mask

# returns True if all output file names exist in directory
def checkFileNames(dirName):
    
    # make sure that file names get generated first
    if len( vNames ) == 0:
        createIndexNames()
    
    if verbose:
        print("\t...Checking voxelwise image directory", dirName)
    
    # adjust outDir if necessary
    if len(dirName) > 0:
        if not dirName.endswith(os.sep):
            dirName += os.sep
    
    # check if directory exists
    if not os.path.exists(dirName):
        print('\t...Creating directory '+ dirName)
        os.makedirs(dirName)
        return False
    
    # check files that might already be there
    existingFiles = os.listdir(dirName)
    nPre = len(existingFiles)
    if verbose:
        print('\t...Directory exists with {0} files'.format(nPre))
    
    # count up how many in the mask already exist
    tallyExist = 0; tallyMask = 0
    nVox = len( vMask )
    for v in range(nVox):
        if not vMask[v]:
            continue
        tallyMask += 1
        
        name = vNames[v] + fileExt
        if name in existingFiles:
            tallyExist += 1
    
    print("\t...{0} of {1} files exist".format(tallyExist, tallyMask))
    return tallyExist == tallyMask

def createVoxels1D(outDir):
    
    nVox = len(vTable)
    print("\nCreating {0} voxelwise 1D images:".format(nVox))
    loadSeriesImage(imagePrefix)
    
    for i in range(nVox):
        
        if not vMask[i]:
            continue
        
        xyz = vTable[i]
        
        # get series data for this voxel
        vSlice = imgSeries[ xyz[0], xyz[1], xyz[2] ]
        
        # get pre-prepared output name for this voxel
        out = outDir + vNames[i] + fileExt
        
        # save voxel slice to file
        print("\t...Saving voxel {0}".format(out))
        nib.save(nib.Nifti1Image(vSlice, nii.affine, dtype=np.float32), out)
    
    if referenceFSL:
        nSeries = len( idSeries )
        print("\t...Verifying versus FSL-created reference images")
        # for each voxel in lookup table
        for i in range(nVox):
            xyz = vTable[i]
            
            # get series data for this voxel
            v = imgSeries[ xyz[0], xyz[1], xyz[2] ]
            
            # get pre-prepared output name for this voxel
            out = outDir1 + vNames[i]
            
            # check loading the voxel file back in again
            niiVoxel = nib.load(out+fileExt)
            imgVoxel = niiVoxel.get_fdata()
            voxEqual = 0
            for t in range(nSeries):
                if (imgVoxel[t] == v[t]):
                    voxEqual += 1
            if voxEqual == nSeries:
                print("\t...All {0} values equal in {1}".format(nSeries, out))
            else:
                print("\t...Only {0} of {1} values equal".format(voxEqual, nSeries))
            
            # single voxel "time-series"
            if not os.path.exists(out +'_t'+ fileExt):
                print("\t...Creating {0}_t with fslroi system call".format(out))
                fslroicmd = 'fslroi {0} {1}_t {2} 1 {3} 1 {4} 1'
                os.system(fslroicmd.format(imagePrefix, out, xyz[0],xyz[1],xyz[2]))
                
            # check _t image values
            niiVoxelT = nib.load(out +'_t'+ fileExt)
            imgVoxelT = niiVoxelT.get_fdata()
            voxEqualT = 0
            for t in range(nSeries):
                if (imgVoxelT[0,0,0,t] == v[t]):
                    voxEqualT += 1
            if voxEqualT == nSeries:
                print("\t...All {0} values equal in {1}_t".format(nSeries, out))
            else:
                print("\t...Only {0} of {1} values equal".format(voxEqualT, nSeries))
            
            # convert to array in z dimension
            if not os.path.exists(out +'_z'+ fileExt):
                print("\t...Creating {0}_z with fsl2ascii, cat, fslascii2img".format(out))
                # split voxel time-series into many text files
                os.system('fsl2ascii {0}_t {0}_ascii-tmp'.format(out))
                # combine into single file (1,1,N image dimensions)
                os.system('cat {0}_ascii-tmp* > {0}_z.txt'.format(out))
                # remove the temporary text files
                os.system('rm {0}_ascii-tmp*'.format(out))
                # convert combined text into an image
                os.system('fslascii2img {0}_z.txt 1 1 {1} 1 1 1 1 1 {0}_z'.format(out, nSeries))
            
            # check _z image values
            niiVoxelZ = nib.load(out +'_z'+ fileExt)
            imgVoxelZ = niiVoxelZ.get_fdata()
            voxEqualZ = 0
            for t in range(nSeries):
                if (imgVoxelZ[0,0,t] == v[t]):
                    voxEqualZ += 1
            if voxEqualZ == nSeries:
                print("\t...All {0} values equal in {1}_z".format(nSeries, out))
            else:
                print("\t...Only {0} of {1} values equal".format(voxEqualZ, nSeries))
            
            # convert to array in z dimension
            if not os.path.exists(out +'_x'+ fileExt):
                print("\t...Creating {0}_x with fslswapdim system call".format(out))
                # swap dimensions so x is biggest (vector-style)
                os.system('fslswapdim {0}_z z x y {0}_x'.format(out))
            
            # check _x image values
            niiVoxelX = nib.load(out +'_x'+ fileExt)
            imgVoxelX = niiVoxelX.get_fdata()
            voxEqualX = 0
            for t in range(nSeries):
                if (imgVoxelX[t] == v[t]):
                    voxEqualX += 1
            if voxEqualX == nSeries:
                print("\t...All {0} values equal in {1}_x".format(nSeries, out))
            else:
                print("\t...Only {0} of {1} values equal".format(voxEqualX, nSeries))
            
            print( np.where(imgVoxelT == imgVoxelT.max()) )
            print( np.where(imgVoxelZ == imgVoxelZ.max()) )
            print( np.where(imgVoxelX == imgVoxelX.max()) )
            print( np.where(imgVoxel == imgVoxel.max()) )
            print( np.where(v == v.max()) )
            result = np.where( v == v.max() )
            nIndex = len(result)
            if (nIndex > 1):
                print('\t...Multiple voxels with max value:', nIndex )
            for i in range(nIndex):
                arr = result[i]
                # 1D array
                val = arr[0]
                print('\t...ID =', idSeries[val])
            
            # calculate voxel volume from nii header values
            voxel_dims = (nii.header["pixdim"])[1:4]
            voxel_volume = np.prod(voxel_dims)
            if verbose:
                print("\t...Voxel volume:", voxel_volume)
            nz = len(vTable)
            
            os.system('fslstats {0}_t -V'.format(out))
            os.system('fslstats {0}_z -V'.format(out))
            os.system('fslstats {0}_x -V'.format(out))
            os.system('fslstats {0} -V'.format(out))
            print("{0} {1}".format(nz, voxel_volume * nz))
            os.system('fslstats {0}_t -R'.format(out))
            os.system('fslstats {0}_z -R'.format(out))
            os.system('fslstats {0}_x -R'.format(out))
            os.system('fslstats {0} -R'.format(out))
            print("{0} {1}".format(imgVoxel.min(), imgVoxel.max()) )
            os.system('fslstats {0}_x -d {0}'.format(out))

def createVoxelsCC(outDir):
    nVox = len(vTable)
    print("\nCreating {0} voxelwise correlation images:".format(nVox))
    loadSeriesImage(imagePrefix)
    for i in range(nVox):
        
        if not vMask[i]:
            continue
        
        xyz = vTable[i]
        
        # get series data for this voxel
        vSlice = imgSeries[ xyz[0], xyz[1], xyz[2] ]
        
        # get pre-prepared output name for this voxel
        out = outDir + vNames[i] + fileExt
        
        if (os.path.exists(out)):
            if verbose:
                print("\t...Skipping existing correlation {0}".format(out))
            continue
        
        # create correlation image
        if verbose:
            print("\t...Finding correlation values for {0}".format(vNames[i]))
        imgCorr = np.zeros(nii.shape)
        for j in range(nVox):
            fj = vTable[j]
            
            # get series data for this voxel
            v2 = imgSeries[ fj[0], fj[1], fj[2] ]
            
            # calling pearsonr when std==0 shows a warning message
            if (np.std(v2) == 0):
                # this shouldn't happen anymore since looping on voxel table
                # but it is happening somehow ?!
                print("\t...Unexpected STD=0", j, fj, vNames[j])
                # leave imgeCorr at its default value of zero
            else:
                result = scipy.stats.pearsonr(vSlice, v2)
                valCC = np.abs( result.statistic )
                imgCorr[ fj[0], fj[1], fj[2] ] = valCC
        
        print("\t...Saving image {0}".format(out))
        nib.save(nib.Nifti1Image(imgCorr, nii.affine, dtype=np.float32), out)

# checks vTable versus input image, prints IDs for matching voxels
def createInputForMACM(image, prefixName):
    
    bmapIDs = []
    
    # find nonzero voxels in input that are at foci in voxelTable
    nVox = len( vTable )
    for i in range(nVox):
        # get input image value at this foci
        xyz = vTable[i]
        val = image[ xyz[0], xyz[1], xyz[2] ]
        if (val == 0):
            continue
        
        # get series data for this voxel
        vSlice = []
        if imgSeries.size > 0:
            # series image is loaded and available
            vSlice = imgSeries[ xyz[0], xyz[1], xyz[2] ]
        else:
            # load voxel file for this voxel
            vSlice = nib.load( outDir1 + vNames[i] + fileExt ).get_fdata()
        
        # check where it is nonzero
        array = np.where( vSlice != 0 )[0]
        if verbose:
            print('\t...Found', str(len(array)), 'ID at', vNames[i])
        
        for index in array:
            bmap = idSeries[index]
            
            # remove file extention
            if bmap.endswith(fileExt):
                bmap = bmap[:-len(fileExt)]
            
            # keep a list of IDs (but we don't need duplicates)
            if not bmap in bmapIDs:
                bmapIDs.append(bmap)
            
            if verbose:
                print('\t\t', bmap)
    
    # TODO: sort IDs so papers will be sequential?
    
    # TODO: split IDs into paper and ID
    workName = prefixName + '_macm.work'
    print("\t...Creating output workspace file", workName)
    workFile = open(workName, 'w')
    
    # write workspace XML header
    header = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n'
    header += '<!DOCTYPE workspace SYSTEM "http://www.brainmap.org'
    header += '/DTDs/Workspace-1.1.dtd">\n<workspace>\n'
    workFile.write(header)
    
    # write which database these IDs are for
    database = '\t<database>\n\t\t<{0}/>\n\t</database>\n'.format(dbName)
    workFile.write( database )
    
    workFile.close()
    
    # TODO: could make this part into a separate script that reads a .work file
    # or into a separate function that takes an arbitrary path & bmapIDs
    metaName = prefixName + '_macm.txt'
    print("\t...Creating output foci file", metaName)
    metaFile = open(metaName, 'w')
    
    # read foci text
    firstFociFile = True
    for bmap in bmapIDs:
        # TODO: check MA Reference relative path to foci text files
        fName = 'vbp_wdb_mni/foci-txt' + os.path.sep + bmap + '.txt'
        if not os.path.exists(fName):
            print('\t...Unable to read', fName)
            continue
        
        fociText = open(fName, 'r')
        fociLines = fociText.readlines()
        if len(fociLines) == 0:
            print('\t...File is empty', fName)
            continue
        
        # write Reference= foci header only once
        if firstFociFile:
            metaFile.write(fociLines[0])
            firstFociFile = False
        
        # remove first line
        fociLines = fociLines[1:]
        
        # otherwise write all lines to the combined foci file
        for line in fociLines:
            metaFile.write(line)
        
        # put an empty line between files
        metaFile.write('\n')
        # TODO: could check for within-paper overlap of coordinates here.
    
    print('\t...Saving combined foci file')
    metaFile.close()

def createInputForCBP(image, prefixName):
    
    # create text files for ROI data
    if verbose:
        print("\t...Creating output text files for", prefixName)
    matrixFile = open(prefixName + "_cc.txt", 'w')
    coordsFile = open(prefixName + "_xyz.txt",  'w')
    
    nVox = len( vTable )
    tally = 0
    for i in range(nVox):
        # get input image value at this foci
        xyz = vTable[i]
        val = image[ xyz[0], xyz[1], xyz[2] ]
        if (val == 0):
            continue
        
        # load voxel file for this voxel
        file = outDirCC + vNames[i] + fileExt
        if verbose:
            print("\t...Reading", file)
        voxCC = nib.load( file ).get_fdata()
        
        # get values from input image for each voxel in lookup table
        voxArray = [ voxCC[f[0],f[1],f[2]] for f in vTable ]
        tally += 1
        
        # save output to file
        matrixFile.write(str(voxArray) + '\n')
        
        # parse vNames to get x,y,z
        if not '_' in vNames[i]:
            print("\t...Can not parse coordinate", vNames[i])
            coordsFile.write(vNames[i] +'\n')
        else:
            under = vNames[i].index('_') + 1
            coord = vNames[i][under:]
            coordsFile.write(coord +'\n')
            if verbose:
                print("\t...Writing row", tally, vNames[i], coord)
    
    matrixFile.close()
    coordsFile.close()
    print("\t...Wrote {0} rows to {1}_cc.txt".format(tally, prefixName))


### --- Main Method --- ###

# first get the index (order of voxels, to convert 3d to 1d)
file = imagePrefix +'_index'+ fileExt
if os.path.exists( file ):
    print("\nLoading index image:")
    print("\t...Reading:", file)
    nii = nib.load(file)
    imgIndex = nii.get_fdata()
else:
    # otherwise, create it from series image data
    createIndexImage(imagePrefix)
    # sets nii and imgIndex

# once index image is loaded, create the lookup table
vTable = createIndexTable(imgIndex)

# decide which voxels in vTable are relevant.  either with start/end or ROI
vMask = setVoxelMask(voxStart, voxEnd, inputNames)

# create the output voxelwise 1D timeseries slice
if MACM:
    print("\nChecking voxelwise 1D images:")
    outDir1 = imagePrefix + '_vox1D' + os.sep
    filesOK = checkFileNames(outDir1)
    if not filesOK:
        createVoxels1D(outDir1)
    
    # load series names/IDs from {prefix}_order.txt
    loadSeriesNames(imagePrefix)

# create the output voxelwise 3D correlation images
if CBP:
    print("\nChecking voxelwise correlation images:")
    outDirCC = imagePrefix + '_voxCC' + os.sep
    filesOK = checkFileNames(outDirCC)
    if not filesOK:
        createVoxelsCC(outDirCC)


# run MACM or CBP on each of the input images
for fName in inputNames:
    prefix = fName
    if prefix.endswith(fileExt):
        prefix = prefix[0:-(len(fileExt))]
    
    # input images have already been checked over in setMask function
    if not fName.endswith(fileExt):
        fName += fileExt
    niiInput = nib.load(fName)
    imgInput = niiInput.get_fdata()
    
    if MACM:
        print("\nPreparing MACM for", prefix)
        createInputForMACM(imgInput, prefix)
    
    if CBP:
        print("\nPreparing CBP for", prefix)
        createInputForCBP(imgInput, prefix)
print()

# https://neurostars.org - "Stack Overflow" for NeuroImaging

#--- fslpy is not working well for me yet ---#

#import fsl
#from fsl import version as fslversion
#from fsl.wrappers import fslstats
#from fsl.scripts import imtest
#from fsl.scripts import imglob
#import fsl.utils as fslutils
#import fsl.utils.platform as fslplatform
#import fsl.scripts.imtest as fsltest

#print('fslpy version:')
#print (fslversion.__version__)
#print('platform:')
#plat = fslplatform.Platform
#print('os={0} fsldir={1} gui={2}'.format(plat.os, plat.fsldir, plat.haveGui))
#stats = fslstats(imagePrefix+fileExt)
#print('stats.r {0}'.format(stats.r))
#fslOK = imtest.main(imagePrefix)
#if not fslOK:
#    print('Input image series failed fsl.imtest({0})'.format(imagePrefix))
#fslOK = imtest.main(imagePrefix+fileExt)
#if not fslOK:
#    print('Input image series failed fsl.imtest({0})'.format(imagePrefix+fileExt))

# try out fsl.utils.filetree and fsl.utils.path
#fslList = imglob.imglob(outDir)
#print("\t...Using fslpy! fsl.scripts.imglob {0}".format(fslList))

# try fsl.utils.image.roi.roi
# returns Image that can be saved directly (no header manipulation step)
