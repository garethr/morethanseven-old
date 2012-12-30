for filename in *.textile;
do
  sed -i '' 's/tags: \[/categories: \[/' $filename
done
