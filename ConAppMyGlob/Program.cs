using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ClassLibraryFileGlobber;

namespace ConAppMyGlob
{
    class Program
    {
        static void Main(string[] args)
        {
            //string argsZero = @"c:\temp\dupstination\t*o\tra*.txt";
            FileGlobber fg = new FileGlobber(args[0]);

            foreach (var v in fg.MatchingFiles)
            {
                // Write the file name in which a match was found.
                Console.WriteLine(">> " + v.FullName);

            }

        }
    }
}
