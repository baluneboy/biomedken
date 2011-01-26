using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ClassLibraryFileGlobber;

namespace ClassLibraryFileGlobber
{
    // FileGlobberFmriAnat derives from FileGlobber and adds 3 properties:
    // PathAnat & FileAnat (both strings), and IsValid bool
    public class FileGlobberFmriAnat : FileGlobber
    {
        protected bool isValid;
        protected string pathAnat;
        protected string fileAnat;

        public bool IsValid { get { return isValid; } }
        public string PathAnat { get { return pathAnat; } }
        public string FileAnat { get { return fileAnat; } }

        // Default constructor for this derived class calls instance constructor of base
        public FileGlobberFmriAnat(string globpattern)
            : base(globpattern)
        {
            // HACK the following should be done the right way, which is what?
            this.isValid = false;
            this.pathAnat = "";
            this.fileAnat = "";

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