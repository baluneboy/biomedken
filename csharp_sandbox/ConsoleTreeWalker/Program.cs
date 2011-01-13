using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace ConsoleApplication1
{

    public class RecursiveFileSearch
    {
        static System.Collections.Specialized.StringCollection log = new System.Collections.Specialized.StringCollection();
        
        static void Main()
        {
            // Create the regular expression to find "c:\temp\dupstination\t*o".
            System.Text.RegularExpressions.Regex patternDir =
                new System.Text.RegularExpressions.Regex(@"^c:\\temp\\dupstination\\t[^\\]*o$");

            // Start with drives if you have to search the entire computer.
            DirectoryInfo diRootDir = new DirectoryInfo(@"c:\temp\dupstination");
            WalkDirectoryTree(diRootDir,patternDir);

            // Keep the console window open in debug mode.
            Console.WriteLine("Press any key");
            Console.ReadKey();
        }

        static void WalkDirectoryTree(System.IO.DirectoryInfo root, System.Text.RegularExpressions.Regex patternDir)
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
                log.Add(e.Message);
            }

            catch (System.IO.DirectoryNotFoundException e)
            {
                Console.WriteLine(e.Message);
            }

            if (files != null)
            {
                // if this directory matches, then dip down deal with files
                //if (strDir.Equals(@"c:\temp\dupstination\two"))
                if ( patternDir.IsMatch(strDir) )
                {
                    //Console.WriteLine("   MATCH dir  " + strDir);
                    foreach (System.IO.FileInfo fi in files)
                    {
                        // In this example, we only access the existing FileInfo object. If we
                        // want to open, delete or modify the file, then
                        // a try-catch block is required here to handle the case
                        // where the file has been deleted since the call to TraverseTree().
                        if (patternDir.IsMatch(fi.Directory.FullName))
                            Console.WriteLine("file  " + fi.FullName);
                    }
                }
                //else
                //    Console.WriteLine("NOTMATCH dir  " + strDir);

                // Now find all the subdirectories under this directory.
                subDirs = root.GetDirectories();

                foreach (System.IO.DirectoryInfo dirInfo in subDirs)
                {
                    // Resursive call for each subdirectory.
                    WalkDirectoryTree(dirInfo,patternDir);
                }
            }
        }
    }

}
