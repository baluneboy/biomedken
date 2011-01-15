using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;

namespace ClassLibraryFileGlobber
{
    public class GlobParts
    {
        private Regex rxpat = new Regex(@"^(?<PATHSTUB>[^\*]*)\\(?<SUBDIR>.*)\\(?<FILE>.*)$");
        private Match m;

        private Boolean arevalid = false;
        private string pathstub;
        private string subdir;
        private string filename;

        public Boolean AreValid { get { return arevalid; } } 
        public string PathStub { get { return pathstub; } }
        public string SubDir { get { return subdir; } }
        public string FileName { get { return filename; } }

        // constructor
        public GlobParts()
        {
        }

        public GlobParts(string str)
        {
            m = rxpat.Match(str);
            if (m.Success)
            {
                pathstub = m.Groups["PATHSTUB"].Value;
                subdir = m.Groups["PATHSTUB"].Value + "\\" + m.Groups["SUBDIR"].Value + "\\";
                filename = m.Groups["FILE"].Value;
                if ( Directory.Exists(pathstub) )
                    arevalid = true;
            }

        }
    }
}
