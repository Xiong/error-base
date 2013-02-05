#! /bin/sh

# This script invokes pod2cpanhtml to generate HTML from POD. 
# This is done so the rendering can be checked by eye. 

pod2cpanhtml lib/Error/Base.pm html/Error/Base.html
pod2cpanhtml lib/Error/Base/Cookbook.pm html/Error/Base/Cookbook.html

exit 0
