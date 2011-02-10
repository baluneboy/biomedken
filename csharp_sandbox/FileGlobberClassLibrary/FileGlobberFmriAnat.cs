using System;
using ClassLibraryFileGlobber;

namespace ClassLibraryFileGlobber
{
    /*
     * FileGlobberFmriAnat derived from FileGlobber and adds 3 properties:
     * - IsValid bool (true when exactly 1 file matches)
     * - PathAnat & FileAnat (both strings)
     */
    public class FileGlobberFmriAnat : FileGlobber
    {
        protected bool isValid;
        protected string pathAnat;
        protected string fileAnat;

        public bool IsValid { get { return isValid; } }
        public string PathAnat { get { return pathAnat; } }
        public string FileAnat { get { return fileAnat; } }

        // Default constructor for this derived class
        public FileGlobberFmriAnat(string globpattern)
            : base(globpattern) // calls instance constructor of base
        {
            // HACK the following should be done the right way, which is what?
            this.isValid = false;
            this.pathAnat = "";
            this.fileAnat = "";
            
            // If only 1 matching file, then its valid
            if (this.MatchCount == 1)
            {
                this.pathAnat = matchingfiles[0].DirectoryName;
                this.fileAnat = matchingfiles[0].Name;
                this.isValid = true;
            }
        }

        public new void print()
        {
            base.print();
            Console.WriteLine("I'm a FileGlobberFmriAnat Class.");
        }
    }

}