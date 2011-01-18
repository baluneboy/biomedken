using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Drawing;

namespace WinAppKiller
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        [DllImport("user32.dll", EntryPoint = "SetWindowPos")]
        public extern static bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

        public static extern IntPtr SetWindowPos(IntPtr hWnd, int hWndInsertAfter, int x, int Y, int cx, int cy, int wFlags);        
        const short SWP_NOMOVE = 0X2;
        const short SWP_NOSIZE = 1;
        const short SWP_NOZORDER = 0X4;
        const int SWP_SHOWWINDOW = 0x0040;        
            
        //static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
        //static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
        //static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
        //static readonly IntPtr HWND_TOP = new IntPtr(0);
        //const UInt32 SWP_NOSIZE = 0x0001;
        //const UInt32 SWP_NOMOVE = 0x0002;
        //const UInt32 SWP_NOZORDER = 0x0004;
        //const UInt32 SWP_NOREDRAW = 0x0008;
        //const UInt32 SWP_NOACTIVATE = 0x0010;
        //const UInt32 SWP_FRAMECHANGED = 0x0020;  /* The frame changed: send WM_NCCALCSIZE */
        //const UInt32 SWP_SHOWWINDOW = 0x0040;
        //const UInt32 SWP_HIDEWINDOW = 0x0080;
        //const UInt32 SWP_NOCOPYBITS = 0x0100;
        //const UInt32 SWP_NOOWNERZORDER = 0x0200;  /* Don't do owner Z ordering */
        //const UInt32 SWP_NOSENDCHANGING = 0x0400;  /* Don't send WM_WINDOWPOSCHANGING */
        //const UInt32 TOPMOST_FLAGS = SWP_NOMOVE | SWP_NOSIZE;

        static void Main()
        {


            //Application.EnableVisualStyles();
            //Application.SetCompatibleTextRenderingDefault(false);
            //Application.Run(new Form1());

            Process[] processes = Process.GetProcessesByName("MRIcroN");
            foreach (Process p in processes)
            {
                //p.CloseMainWindow();
                IntPtr pFoundWindow = p.MainWindowHandle;
                MessageBox.Show(pFoundWindow.ToString());
                //SetWindowPos(pFoundWindow, 0, 0, 0, 0, 0, SWP_NOZORDER | SWP_NOSIZE | SWP_NOZORDER | SWP_SHOWWINDOW);
                Point screenlocation = Screen.AllScreens[1].Bounds.Location;
                SetWindowPos(pFoundWindow, -1, screenlocation.X, screenlocation.Y, Screen.AllScreens[1].Bounds.Width, Screen.AllScreens[1].Bounds.Height, SWP_NOZORDER | SWP_SHOWWINDOW);
            }
        }
    }
}
