using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Text.RegularExpressions;

namespace ClassLibraryFileGlobber
{

    public class RecursiveFileSearch
    {
        private Queue<string> filequeue = new Queue<string>();
        public Queue<string> FileQueue { get { return filequeue; } }

        // constructor
        public RecursiveFileSearch(string basepath, Regex regexdirpattern)
        {
            // We need detailed parsing and work on something like this:
            // (?<DIR>c:\\temp\\dupstin[^\\]*)\\(?<FILE>file[^\\]*\.txt)
            // Create the regular expression to find "c:\temp\dupstination\t*o".
            //Regex regexdirpattern = new Regex(@"^c:\\temp\\dupstination\\t[^\\]*o$");
            
            // Establish root directory info to walk the tree
            DirectoryInfo diRootDir = new DirectoryInfo(basepath);
            WalkDirectoryTree(diRootDir,regexdirpattern);

         }

        private void WalkDirectoryTree(System.IO.DirectoryInfo root,
            Regex regexdirpattern)

        {
            System.IO.FileInfo[] files = null;
            System.IO.DirectoryInfo[] subDirs = null;

            // if this directory does not match pattern, then short-circuit outta here
            string strDir = root.FullName;

            // First, process all the files directly under this folder
            try
            {
                files = root.GetFiles("*.*");
            }
            // This is thrown if even one of the files requires permissions greater
            // than the application provides.
            catch (UnauthorizedAccessException e)
            {
                // This code just writes out the message and continues to recurse.
                // You may decide to do something different here. For example, you
                // can try to elevate your privileges and access the file again.
                Console.WriteLine(e.Message);
            }

            catch (System.IO.DirectoryNotFoundException e)
            {
                Console.WriteLine(e.Message);
            }

            if (files != null)
            {
                // if this directory matches, then dip down deal with files

                strDir = strDir + @"\";
                Console.WriteLine("RXPAT  is " + regexdirpattern.ToString());
                Console.WriteLine("strDir is  " + strDir);
                Console.WriteLine("---------------------------------");

                if (Regex.IsMatch(strDir, regexdirpattern.ToString()))
                {
                    //Console.WriteLine("   MATCH dir  " + strDir);
                    foreach (System.IO.FileInfo fi in files)
                    {
                        // In this example, we only access the existing FileInfo object. If we
                        // want to open, delete or modify the file, then
                        // a try-catch block is required here to handle the case
                        // where the file has been deleted since the call to TraverseTree().
                        if (regexdirpattern.IsMatch(fi.Directory.FullName))
                            this.filequeue.Enqueue(fi.FullName);
                    }
                }

                // Now find all the subdirectories under this directory.
                subDirs = root.GetDirectories();

                foreach (System.IO.DirectoryInfo dirInfo in subDirs)
                {
                    // Resursive call for each subdirectory.
                    WalkDirectoryTree(dirInfo,regexdirpattern);
                }
            }
        }
    }

}
