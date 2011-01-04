using System;

public class Hello
{
    public static int Main(string[] args)
    {
        Console.WriteLine("Hello, World!");
        Console.WriteLine("You entered the following {0} command line arguments:",
           args.Length);
        for (int i = 0; i < args.Length; i++)
        {
            Console.WriteLine("{0}", args[i]);
        }
        return 0;
    }
}