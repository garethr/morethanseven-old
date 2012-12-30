for filename in *.textile;
do
  sed -i '' 's/publish: true/comments: true/' $filename
done
