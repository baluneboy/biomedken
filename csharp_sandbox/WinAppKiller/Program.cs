using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Drawing;
using System.Threading;

namespace WinAppKiller
{
    static class Program
    {
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

        static void Main(string[] args)
        {
            Process myProcess = new Process();

            myProcess.StartInfo.UseShellExecute = false;

            // You can start any process
            myProcess.StartInfo.FileName = @"C:\WINDOWS\notepad.exe"; // @"C:\Program Files\mricron\MRIcroN.exe";
            myProcess.StartInfo.CreateNoWindow = true;
            myProcess.Start();
            myProcess.WaitForInputIdle();
            Thread.Sleep(222);

            // Just set the position, no resize of window
            int myX = 222;
            int myY = 111;
            SetWindowPos(myProcess.MainWindowHandle, new IntPtr(0), myX, myY, 0, 0, 0x0001);

        }
    }
}
