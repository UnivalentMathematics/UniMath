
# Adds an [Export.v] file for each package.
#
# Files will appear alphabetically, not in dependency order.

basename=UniMath

for packagename in $(ls -d ${basename}/*/); do

    tempfile=${packagename}Export.v.temp
    rm -f ${packagename}Export.v ${tempfile}
    touch ${tempfile}
    
    echo "(* This file auto-generated by regenerate-export-files.sh, *)" >> ${tempfile}
    echo "(* and may be re-auto-generated in future, *)" >> ${tempfile}
    echo "(* so any edits made by hand may be lost. *)" >> ${tempfile}
    for filename in $(git ls-files ${packagename}); do
	if [[ $filename == *.v && ! ($filename == *Export.v) ]];
	then
	    filebase=${filename%.v}
	    libname=${filebase//\//.}
	    echo "Require Export ${libname}." >> ${tempfile}
	fi
    done
    
    mv ${tempfile} ${packagename}Export.v
done

