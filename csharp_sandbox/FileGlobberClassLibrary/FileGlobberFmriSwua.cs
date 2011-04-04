using System;
using System.Diagnostics;
using System.IO;
using ClassLibraryFileGlobber;

namespace ClassLibraryFileGlobber
{
    /*
     * FileGlobberFmriSwua derived from FileGlobberFmriAnat
     */
    public class FileGlobberFmriSwua : FileGlobberFmriAnat
    {
        protected bool isValidAnat;
        protected string anatFile;
        protected bool isValidSwua;
        protected string pathSwua;
        protected string firstFileSwua;

        public bool IsValidAnat { get { return isValidAnat; } }
        public string AnatFile { get { return anatFile; } }
        public bool IsValidSwua { get { return isValidSwua; } }
        public string PathSwua { get { return pathSwua; } }
        public string FirstFileSwua { get { return firstFileSwua; } }
        public string FullNameSwua { get { return @pathSwua + @"\" + @firstFileSwua; } }

        // Default constructor for this derived class
        public FileGlobberFmriSwua(string globpatAnat)
            : base(globpatAnat) // calls instance constructor of base
        {
            // HACK the following should be done the right way, which is what?
            this.isValidAnat = base.IsValid;
            this.anatFile = base.FullName;
            this.isValidSwua = false;
            this.pathSwua = "";
            this.firstFileSwua = "";

            // Get task string from directory name
            FileInfo fiTask = new FileInfo(this.anatFile);
            string task = fiTask.Directory.Name;

            // Get study directory from parent dir of parent dir of anat file
            DirectoryInfo diResults = Directory.GetParent(base.PathAnat);
            string resultsDir = diResults.FullName;
            DirectoryInfo diStudy = Directory.GetParent(resultsDir);
            string studyDir = diStudy.FullName;

            // Build globpat for swua
            string globpatSwua = @studyDir + @"\series_*_" + task + @"_*\swua2*.img";

            // Do fileglob for swua
            FileGlobber fg = new FileGlobber(globpatSwua);

            // If one anat file and [for now] more than 50 matching swua files, then valid and just use first swua
            if (base.MatchCount==1 & fg.MatchCount > 50)
            {
                this.pathSwua = fg.MatchingFiles[0].DirectoryName;
                this.firstFileSwua = fg.MatchingFiles[0].Name;
                this.isValidSwua = true;
            }
        }

        public new void DebugShow()
        {
            base.DebugShow();
            Debug.WriteLine("IsValid: " + this.IsValid);
            Debug.WriteLine("FullName: " + this.FullName);
        }
    }

}