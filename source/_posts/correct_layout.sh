for filename in *.textile;
do
  sed -i '' 's/kind: article/layout: post/' $filename
done
