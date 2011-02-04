﻿#define DEMO
//#define MYTEST

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

#if (!DEMO && MYTEST)
            Console.WriteLine("MYTEST is defined");
            FileGlobberFmriAnat FileGlobberFmriAnat = new FileGlobberFmriAnat(args[0]);
            FileGlobberFmriAnat.print();
            ((FileGlobber)FileGlobberFmriAnat).print();
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
#else
            Console.WriteLine("DEMO and MYTEST are not defined");
#endif

        }
    }
}