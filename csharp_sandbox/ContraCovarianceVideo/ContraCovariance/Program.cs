using System;
using System.Collections.Generic;
using Excel = Microsoft.Office.Interop.Excel;

/*
 * The code from Eric Lippert's video on CoVariance and Contravariance.
 * The Titles:
 *  How Do I Use Covariance and Contravariance Part 1
 *  How Do I Use Covariance and Contravariance Part 2
 * URLs at publication time: 
 *  http://msdn.microsoft.com/en-us/vcsharp/ee672314.aspx
 *  http://msdn.microsoft.com/en-us/vcsharp/ee672319.aspx
 */
namespace ContraCovariance
{
    abstract class Person { public string Name { get; set; } }
    abstract class Employee : Person { }
    class Manager : Employee { }
    class Customer : Person { }

    abstract class Game { }
    abstract class BoardGame : Game { }
    class Chess : BoardGame
    {
        protected string _color;
        public string Color { get { return _color; } }

        public Chess(string color = "red")
        {
            _color = color;
        }

        public void Show()
        {
            Console.WriteLine("my color is: " + this.Color);
            Console.ReadLine();
        }
    }

    public interface ITaggedItem<out T>
    {
        T Value { get; }
        string Tag { get; }
    }

    public class TaggedItem<T> : ITaggedItem<T>
    {
        public T Value { get; private set; }
        public string Tag { get; private set; }
        public TaggedItem(T Value, string tag)
        {
            this.Value = Value;
            this.Tag = tag;
        }

        public TaggedItem()
        {
            // TODO: Complete member initialization
        }
    }

    /// <summary>
    /// "Covariant is about stuff coming out, contravariant is almost
    /// always about stuff coming in. There are some exceptions to that
    /// rule, but those are complicated weird situations that we aren't 
    /// going to talk about today." - Eric Lippert
    /// </summary>
    class Program
    {
        delegate void MyAction<in T1, in T2>(T1 t1, T2 t2);

        public static void M1(Person[] persons)
        {
            persons[0] = new Customer();
        }

        public static void M2(IEnumerable<Person> persons) { }

        public static void M3(ITaggedItem<BoardGame> taggedGame) { }

        static void Main(string[] args)
        {
            Employee[] employees = new[] { new Manager() };
            // M1(employees); // author commented this out, not me
            IEnumerable<Employee> emp2 = employees;
            M2(emp2);

            Chess c = new Chess(color:"brown");
            c.Show();

            //var nr = new TaggedItem<Microsoft.Office.Tools.Excel.NamedRange>();
            var chess = new TaggedItem<Chess>(new Chess(), "Civil War");
            M3(chess);

            // TaggedItem<Game> game = chess; // author commented this out, not me
            MyAction<Person, string> setName = (p, s) => { p.Name = s; };
            MyAction<Employee, string> setName2 = setName;

            IComparable<Employee> comp1 = null;
            IComparable<Manager> comp2 = comp1;            
        }
    }
}
