#! /bin/sh
# Backup current working directory for later
pwd = `pwd`
rootdir = ""

if [ $1 ]; then
    if [ -d $1 ]; then
        rootdir = $1
        echo "Running on - $1"
        cd $1
    else
        echo "$1 is not a rootdirectory"
        exit
    fi
else
    rootdir = `pwd`
    echo "Running on - `pwd`"
fi

# List of root level directories we are interested in.
#declare -a dirs=("product" "bfc" "ao" "comp" "infra")
declare -a dirs=("product" "ao" "comp")

echo 'Deleting existing cscope files...'
rm -rfv cscope.*
echo 'Deleting existing tags files...'
rm -rfv tags*

for dir in "${dirs[@]}"
do
    if [ -d $dir ]; then
        cd "$dir"
        echo "Finding files in: `pwd`"

        if [ "$2" == "include" ]; then
            echo "Including kernel files too..."
            find `pwd` -type f -print | egrep -i "\.(c|h|cpp)$" >> $rootdir/cscope.files
        else
            # Don't include kernel and stub files
            find `pwd` -type f -and -not -iwholename "*/*kernel*/*" -and -not -iwholename "*stub*" -print | egrep -i "\.(c|h|cpp)$" >> $rootdir/cscope.files
        fi

        cd $rootdir
    else
        echo "Invalid $dir"
    fi
done

echo 'Building cscope database...'
cscope -b -q

echo 'Building ctags database...'
ctags --extra=+f --c-kinds=+p --fields=+lS -L $rootdir/cscope.files

cd $pwd
echo 'All done.'
