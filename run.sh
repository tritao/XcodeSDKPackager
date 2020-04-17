set -ex
osxcross/tools/gen_sdk_package.sh

if [ -n "$TRAVIS_OSX_IMAGE" ]; then
    for filename in *.sdk*; do
        EXT=`echo $filename | sed 's/.*sdk//'`
        XCODE_VERSION=`python -c "print(\"$TRAVIS_OSX_IMAGE\".capitalize())"`
        mv $filename $(basename "$filename" $EXT)-$XCODE_VERSION$EXT
    done
fi