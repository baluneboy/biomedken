using System;
using System.Diagnostics;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace ClassLibraryFileGlobber
{
    public class FileGlobber
    {
        protected GlobParts globparts = new GlobParts();
        protected List<FileInfo> matchingfiles;

        public GlobParts GlobParts { get { return globparts; } }
        public List<FileInfo> MatchingFiles { get { return matchingfiles; } }
        public int MatchCount { get { return matchingfiles.Count; } }

        // Default constructor
        public FileGlobber() {}

        // Instance constructor
        public FileGlobber(string globpattern)
        {
            globparts = new GlobParts(globpattern);
            matchingfiles = GetMatchingFiles(globparts.BasePath,
                                             globparts.DirPattern,
                                             globparts.FilePattern);
        }

        // Class method to get list of files that match both filename & dirname patterns
        protected List<FileInfo> GetMatchingFiles(
            string startfolder,
            string folderpattern,
            string namepattern)
        {

            // Take a snapshot of the file system!
            List<FileInfo> fileList = GetFiles(startfolder);

            // Query that produces list of files matching both filename & dirname patterns
            var queryMatchingFiles =
                from file in fileList
                where Regex.IsMatch(file.Name, namepattern) &&
                      Regex.IsMatch(file.DirectoryName, @"^" + folderpattern + "$")
                select file;

            return queryMatchingFiles.ToList();

        }

        // Base class method assumes that the application has discovery 
        // permissions for all folders under the specified path to get files.
        private List<FileInfo> GetFiles(string path)
        {
            string[] fileNames = null;
            List<FileInfo> files = new List<FileInfo>();

            if (Directory.Exists(path)) //got rid of: throw new DirectoryNotFoundException();
            {
                fileNames = Directory.GetFiles(path, "*.*",
                                               SearchOption.AllDirectories);
                foreach (string name in fileNames)
                {
                    files.Add(new FileInfo(name));
                }
            }
            return files;
        }

        public void DebugShow()
        {
            Debug.WriteLine("GlobParts.DirPattern: " + this.GlobParts.DirPattern);
            Debug.WriteLine("GlobParts.FilePattern: " + this.GlobParts.FilePattern);
            Debug.WriteLine("MatchCount: " + this.MatchCount);
            if (this.MatchCount>0)
                Debug.WriteLine("MatchingFiles[0]: " + this.MatchingFiles[0].FullName);
        }
    }
}