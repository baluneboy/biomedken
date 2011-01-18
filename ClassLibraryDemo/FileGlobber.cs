using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace ClassLibraryFileGlobber
{
    public class FileGlobber
    {
        private GlobParts globparts = new GlobParts();
        private IEnumerable<FileInfo> matchingfiles;
        private int matchcount;

        public GlobParts GlobParts { get { return globparts; } }
        public IEnumerable<FileInfo> MatchingFiles { get { return matchingfiles; } }
        public int MatchCount { get { return matchcount; } }

        // constructor(s)
        public FileGlobber(string globpattern)
        {
            matchcount = 0;
            globparts = new GlobParts(globpattern);
            matchingfiles = GetMatchingFiles(globparts.BasePath,
                                             globparts.DirPattern,
                                             globparts.FilePattern);
            foreach (var f in matchingfiles)
                matchcount = matchcount + 1;

        }

        private IEnumerable<FileInfo> GetMatchingFiles(
            string startfolder,
            string folderpattern,
            string namepattern)
        {

            // Take a snapshot of the file system!
            IEnumerable<FileInfo> fileList = GetFiles(startfolder);

            // This query produces a list of files that match.
            var queryMatchingFiles =
                from file in fileList
                where Regex.IsMatch(file.Name, namepattern) &&
                      Regex.IsMatch(file.DirectoryName, @"^" + folderpattern + "$")
                select file;

            return queryMatchingFiles;

        }

        // This method assumes that the application has discovery 
        // permissions for all folders under the specified path.
        private IEnumerable<FileInfo> GetFiles(string path)
        {
            string[] fileNames = null;
            List<FileInfo> files = new List<FileInfo>();

            if (Directory.Exists(path)) //CHANGED LOGIC: throw new DirectoryNotFoundException();
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
    }
}