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
            FileGlobberFmriAnat fga = new FileGlobberFmriAnat(args[0]);

            if (fga.IsValid)
            {
                Console.WriteLine("FA " + fga.FileAnat);
                Console.WriteLine("PA " + fga.PathAnat);
            }
            else
                Console.WriteLine("not valid bc MatchCount is " + fga.MatchCount);

            //FileGlobberFmriAnat FileGlobberFmriAnat = new FileGlobberFmriAnat();
            //FileGlobberFmriAnat.print();
            //((FileGlobber)FileGlobberFmriAnat).print();
            //Console.ReadLine();

        }
    }
}
