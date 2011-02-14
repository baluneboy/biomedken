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
        private string basepath;
        private string dirpattern;
        private string filepattern;
        private Regex regexdirpattern = new Regex("");
        private Regex regexfilepattern = new Regex("");

        public Boolean AreValid { get { return arevalid; } } 
        public string BasePath { get { return basepath; } }
        public string DirPattern { get { return dirpattern; } }
        public string FilePattern { get { return filepattern; } }
        public Regex RegexDirPattern { get { return regexdirpattern; } }
        public Regex RegexFilePattern { get { return regexfilepattern; } }

        // constructors
        public GlobParts()
        {
        }

        public GlobParts(string str)
        {
            m = rxpat.Match(str);
            if (m.Success)
            {
                basepath = m.Groups["PATHSTUB"].Value;

                dirpattern = m.Groups["PATHSTUB"].Value + "\\" + m.Groups["SUBDIR"].Value;
                dirpattern = @dirpattern.Replace(@"\", @"\\").Replace(@"*", @"[^\\]*");
                regexdirpattern = new Regex(dirpattern);

                filepattern = m.Groups["FILE"].Value;
                filepattern = filepattern.Replace(@"\", @"\\").Replace(@"*", @"[^\\]*").Replace(@".", @"\.");
                regexfilepattern = new Regex(filepattern);
                                
                if ( Directory.Exists(basepath) )
                    arevalid = true;
            }

        }
    }
}
