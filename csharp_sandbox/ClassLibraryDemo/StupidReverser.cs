using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ClassLibraryDemo
{
    //public class StringReverser
    //{
    //    private string str;
    //    public string pub;

    //    public string StringReverser(string s)
    //    {
    //        str = s + "suffix";
    //        return str;
    //    }

    //    private string Reverse2(string x)
    //    {
    //        char[] charArray = new char[x.Length];
    //        int len = x.Length - 1;
    //        for (int i = 0; i <= len; i++)
    //            charArray[i] = x[len - i];
    //        return new string(charArray);
    //    }
    //}

    public class StringReverser
    {
        private string withSuffix;
        private int oldLength = 11;

        public int NewLength
        {
            get { return 11+3; }
            set
            {
                if (value <= 65 && value >= 18)
                {
                    oldLength = value;
                }
                else
                    oldLength = 18;
            }
        }
        public string RevStr
        {
            get { return withSuffix; }
            set { withSuffix = value + "suffix"; }
        }
    }

    public class Employee
    {
        public int salary;

        public Employee(int annualSalary)
        {
            salary = annualSalary;
        }

        public Employee(int weeklySalary, int numberOfWeeks)
        {
            salary = weeklySalary * numberOfWeeks;
        }
    }

    public class SimpleMath
    {
        public int sum;
        public int sqrFirst;

        public int AddTwoNumbers(int number1, int number2)
        {
            return number1 + number2;
        }

        public int SquareANumber(int number)
        {
            return number * number;
        }

        public SimpleMath(int number1, int number2)
        {
            sum = this.AddTwoNumbers(number1,number2);
            sqrFirst = this.SquareANumber(number1);
        }
    }

}