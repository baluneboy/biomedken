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
            globparts = new GlobParts(pat);
            globpattern = pat;

            // if valid glob pattern, populate the file queue
            if (globparts.AreValid)
            {
                filequeue.Enqueue(globpattern);
                filequeue.Enqueue("bye for now");
            }
            else // do something not so awesome
            {
                string msg = String.Format("badInput:invalidGlobPattern='{0}'", pat);
                throw new ArgumentException(msg);
            }

        }

    }

}