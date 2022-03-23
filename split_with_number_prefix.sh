#split -l "$linelimit" "$infile" "$prefix"
i=1
# to put "suffixlen" digits at the end
suffixlen=3
for file in "$1"*; do
    # to make 2 as 002 etc.
    suffix=$(printf "%0${suffixlen}d" $i)
    # actual renaming
    mv "$file" "$1$suffix"
    ((i++))
done
