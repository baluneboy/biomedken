using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ClassLibraryFileGlobber
{
    public class FileGlobber
    {
        private GlobParts globparts = new GlobParts();
        public GlobParts GlobParts { get { return globparts; } }

        private string globpattern;
        public string GlobPattern { get { return globpattern; } }

        private Queue<string> filequeue = new Queue<string>();
        public Queue<string> FileQueue { get { return filequeue; } }

        // constructor
        public FileGlobber(string pat)
        {
            globpattern = pat;
            globparts = new GlobParts(globpattern);

            // if valid glob pattern, populate the file queue
            if (globparts.AreValid)
            {
                RecursiveFileSearch rfs = new RecursiveFileSearch(globparts.BasePath,
                    globparts.RegexDirPattern);
                filequeue = rfs.FileQueue;
            }
            else // do something not so awesome
            {
                string msg = String.Format("badInput:invalidGlobPattern='{0}'", pat);
                throw new ArgumentException(msg);
            }

        }

    }

}