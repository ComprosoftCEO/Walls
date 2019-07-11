project="Walls"

mainfile="Main"
outfile=$project

echo "Assembling $project:"

dasm $mainfile.asm -l$outfile.txt -f3 -v5 -o$outfile.bin
if [ $? -ne 0 ]; then
	echo "Error! Aborting..."
	return;
fi

echo ""
echo "It is finished. Open file?"
echo "(S)tella, (Z)26, or (E)xit"

while true; do
read -rsn1 input
if [ "$input" = "z" ]; then
	z26 "$outfile.bin"
	break
fi

if [ "$input" = "s" ]; then
	stella "$outfile.bin"
	break
fi

if [ "$input" = "e" ]; then
	break
fi
done
