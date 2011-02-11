//#define DEMO
//#define MYTEST
//#define MYDEMO

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using ClassLibraryFileGlobber;

namespace ConAppMyGlob
{
    class Program
    {
        static void Main(string[] args)
        {

#if (!DEMO && MYTEST)

            Console.WriteLine("MYTEST is defined");
            FileGlobber fg = new FileGlobber(@"Y:\adat\*\pre\study_*\results\*\*_pre_*_perhemiactvox.csv");
            foreach (FileInfo fi in fg.MatchingFiles)
                Console.WriteLine(fi.Name);
            Console.ReadLine();

#elif (DEMO && !MYTEST)

            Console.WriteLine("DEMO is defined");
            FileGlobberFmriAnat fga = new FileGlobberFmriAnat(args[0]);
            if (fga.IsValid)
            {
                //Console.WriteLine("FA " + fga.FileAnat);
                System.IO.Directory.CreateDirectory(fga.PathAnat.Replace(@"y:\adat", @"t:\previousResults") + @"\..");
                Console.WriteLine("created " + fga.PathAnat.Replace(@"y:\adat", @"t:\previousResults") + @"\..");
            }
            else
                Console.WriteLine("not valid bc MatchCount is " + fga.MatchCount);

            FileGlobberFmriAnat fgaW = new FileGlobberFmriAnat(args[0].Replace("shoulder","wrist"));
            if (fgaW.IsValid)
            {
                //Console.WriteLine("FA " + fga.FileAnat);
                System.IO.Directory.CreateDirectory(fgaW.PathAnat.Replace(@"y:\adat", @"t:\previousResults") + @"\..");
                Console.WriteLine("created " + fgaW.PathAnat.Replace(@"y:\adat", @"t:\previousResults") + @"\..");
            }
            else
                Console.WriteLine("not valid bc MatchCount is " + fga.MatchCount);

#elif (DEMO && MYTEST)
            Console.WriteLine("DEMO and MYTEST are defined");
#elif (MYDEMO)
    string tempPath = @"c:\temp\trash\todelete";
    System.IO.DirectoryInfo targ = new System.IO.DirectoryInfo(tempPath);
    bool success = false;
    foreach (System.IO.FileSystemInfo fsi in targ.IterateFiles(false))
    {
    Console.Write(fsi.FullName);
    Console.Write(" Attributes:" + fsi.Attributes.ToString("f"));
    if (!fsi.Attributes.ContainsAnyOf(
            System.IO.FileAttributes.System | 
            System.IO.FileAttributes.Temporary))
    {
        success = true;
        try
        {
        fsi.Delete();
        }
        catch (Exception ex)
        {
        success = false;
        Console.Write(ex.ToString());
        }
        Console.Write(success ? " Deleted" : " Could not Delete!");
    }
    Console.WriteLine("");
    }
    Console.ReadLine();

#else
            Console.WriteLine("nothing to do");
#endif

        }
    }
}