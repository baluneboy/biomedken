using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ClassLibraryFileGlobber;

namespace ClassLibraryFileGlobber
{

    public class ParentDemo
    {
        string ParentDemoString;
        public ParentDemo()
        {
            Console.WriteLine("ParentDemo Constructor.");
        }
        public ParentDemo(string myString)
        {
            ParentDemoString = myString;
            Console.WriteLine(ParentDemoString);
        }
        public void print()
        {
            Console.WriteLine("I'm a ParentDemo Class.");
        }
    }

    public class ChildDemo : ParentDemo
    {
        public ChildDemo()
            : base("From Derived")
        {
            Console.WriteLine("ChildDemo Constructor.");
        }
        public new void print()
        {
            base.print();
            Console.WriteLine("I'm a ChildDemo Class.");
        }
        public static void NotMain()
        {
            ChildDemo ChildDemo = new ChildDemo();
            ChildDemo.print();
            ((ParentDemo)ChildDemo).print();
            Console.ReadLine();
        }
    }

}
