using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ClassLibraryFileGlobber;

namespace ConsoleApplication1
{
    class Program
    {
        static void Main(string[] args)
        {
            string argsZero = @"C:\temp\dupstination\t*o\tra*.txt";
            // Glob the pattern
            //FileGlobber fg = new FileGlobber(args[0]);
            FileGlobber fg = new FileGlobber(argsZero);
            //System.Console.WriteLine("GlobPattern is " + fg.GlobPattern);
            //System.Console.WriteLine("AreValid " + fg.GlobParts.AreValid + " 4 " + fg.GlobParts.BasePath);
            //System.Console.WriteLine("DirPattern is " + fg.GlobParts.DirPattern);
            //System.Console.WriteLine("FilePattern is " + fg.GlobParts.FilePattern);
            
            foreach (string fileName in fg.FileQueue)
            {
                System.Console.WriteLine("FOUND FILE: " + fileName);
            }

        }
    }
}
