Thank you for downloading this simple text search and replace program.  The following is a 
brief introduction to the files, and how you can use them.


The FINDANDREPLACE tool consists of:

findandreplace.m
findandreplace.fig
findreplace.m
rfindreplace.m

These files should be placed in a directory on your MATLAB path.    To invoke the GUI,
type the following at the MATLAB prompt:

findandreplace


This will open the graphical interface for the tool.   You can also call findreplace.m and
rfindandreplace.m on their own or from an M-file if no GUI is needed.   For example, to 
do a recursive search in the current directory for the string 'fid', in all files of type
.TXT and .M, you can invoke the non-GUI search and replace function like this:


rfindreplace('.', 'fid', -1, 1, {}, strvcat('.txt', '.m'))


There is extra documentation about the inputs and outputs of RFINDREPLACE in the M-file itself.
Please experiment with the functions and code as much as you can, to make this tool useful for your
needs.

Thank you and please let me know of any issues!


Matthias Beebe
mbeebe@MathWorks.com