#!/bin/bash
set -e

# given a directory of images and an output name (without extension)
DIR=$1
OUT_IMG=$2

# TODO: optionally given a text file of the desired order of files

# assume images are compressed
EXT=".nii.gz"

# use a predictable sort order
export LC_ALL=C

# change directories so order file doesn't include paths
# save current working directory so output goes where expected
CWD=`pwd`
cd ${DIR}

# create text list of files in dataset for reference
OUT_TXT="${2}_order.txt"
for IMAGE in *${EXT}
do
  echo $IMAGE >> ${CWD}/${OUT_TXT}
done

#fslmerge -t ${CWD}/${OUT_IMG} *${EXT}
#find . -maxdepth 1 -type f -name '*${EXT}' -exec fslmerge -t ${CWD}/${OUT_IMG} {} \;

# try imglob
echo "calling fslmerge imglob..."
fslmerge -t ${CWD}/${OUT_IMG} `imglob -oneperimage *`

if [ -f ${CWD}/${OUT_IMG}${EXT} ]
then
  echo "it worked!"
else
  echo "it did not work :("
  #clean up
  rm ${CWD}/${OUT_TXT}
fi


# source the proper FSL files
#FSLDIR=/usr/local/fsl/
#. ${FSLDIR}/etc/fslconf/fsl.sh
