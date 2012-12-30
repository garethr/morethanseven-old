for filename in *.textile;
do
  newname=$(echo $filename | sed 's/_/-/g');
  mv $filename $newname;

  #sed 's/kind: article/layout: post/' $newname > $newname

done
