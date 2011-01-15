using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;

namespace ConAppLINQ
{
    class QueryWithRegEx
    {
        public static void Main()
        {
            string startFolder = @"c:\temp\dupstination\";
            string folderPattern = @".*x.*";
            string namePattern = @".*Y.*";

            // Take a snapshot of the file system!
            IEnumerable<FileInfo> fileList = GetFiles(startFolder);

            // This query produces a list of files that match.
            var queryMatchingFiles =
                from file in fileList
                where Regex.IsMatch(file.Name,namePattern) &&
                    Regex.IsMatch(file.DirectoryName,folderPattern)
                select file;

            foreach (var v in queryMatchingFiles)
            {
                // Write the file name in which a match was found.
                Console.WriteLine(v.DirectoryName);
                Console.WriteLine(v.Name);

            }

            // Keep the console window open in debug mode
            Console.WriteLine("Press any key to exit");
            Console.ReadKey();
        }

        // This method assumes that the application has discovery 
        // permissions for all folders under the specified path.
        static IEnumerable<FileInfo> GetFiles(string path)
        {
            if (!Directory.Exists(path))
                throw new DirectoryNotFoundException();

            string[] fileNames = null;
            List<FileInfo> files = new List<FileInfo>();

            fileNames = Directory.GetFiles(path, "*.*",
                SearchOption.AllDirectories);

            foreach (string name in fileNames)
            {
                files.Add(new FileInfo(name));
            }
            return files;
        }
    }
}