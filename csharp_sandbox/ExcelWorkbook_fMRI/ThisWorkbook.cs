using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Xml.Linq;
using System.Threading;
using Microsoft.Office.Tools.Excel;
using Microsoft.VisualStudio.Tools.Applications.Runtime;
using Excel = Microsoft.Office.Interop.Excel;
using Office = Microsoft.Office.Core;
//using MySplash;

namespace ExcelWorkbook_fMRI
{
    public delegate void InvokeClose();

    public partial class ThisWorkbook
    {
        private Form m_splashScreen = new Form();

        private void ThisWorkbook_Startup(object sender, System.EventArgs e)
        {

            //Thread splashthread = new Thread(new ThreadStart(SplashScreen.ShowSplashScreen));
            //splashthread.IsBackground = true;
            //splashthread.Start();
            
            //SplashScreen.UdpateStatusText("Remember that double-click of any cell in run sheet launches processing.");
            //Thread.Sleep(444);
            //SplashScreen.UdpateStatusTextWithStatus("Success Message", TypeOfMessage.Success);
            //// MessageBox.Show("Remember that double-click of any cell in run sheet launches processing.");
            //SplashScreen.UdpateStatusText("Ready to process in MRIcroN, hit 'Process' button...");
            //Thread.Sleep(444);
            //SplashScreen.CloseSplashScreen();

            // NativeWindow actually does a subclass (which is unnecessary)
            // Creating your own IWin32Window implementation might be preferable
            // as it would be safer.
            IntPtr hwndExcel = new IntPtr(Application.Hwnd);
            NativeWindow parent = new NativeWindow();
            parent.AssignHandle(hwndExcel);

            try
            {

                Thread t = new Thread(SplashScreenProc);
                t.Start(parent);
                Thread.Sleep(1111);

                // Consider: might want to use an event for synchronization to ensure
                // that the splash screen is displayed before you start your operation.

                // Do some long operation.
                for (int i = 1; i < 1000; i++)
                {
                    //Excel.Range r = (Excel.Range)this.Cells[i, 1];
                    //r.Value2 = i;
                    Thread.Sleep(1);
                }
                ActivateRunSheet();

                // Must use invoke here because we are calling cross-thread.
                InvokeClose invokeClose = new InvokeClose(m_splashScreen.Close);
                m_splashScreen.Invoke(invokeClose);

            }

            finally
            {
                // Must always undo the subclass or you can crash!
                parent.ReleaseHandle();
            }

        }

        // Display the splash screen
        private void SplashScreenProc(object param)
        {
            // UNDONE: position the splash screen.
            IWin32Window parent = (IWin32Window)param;
            m_splashScreen.Text = "Please wait...";
            m_splashScreen.ShowDialog(parent);
        }

        private void ThisWorkbook_Shutdown(object sender, System.EventArgs e)
        {
        }

        // get the run sheet and set bool true
        public void ActivateRunSheet()
        {
            Microsoft.Office.Interop.Excel._Worksheet wsRun = new Microsoft.Office.Interop.Excel.Worksheet();
            bool hasRun = false;
            // HACK there has got to be a better way than looping to get this info!?
            foreach (Microsoft.Office.Interop.Excel.Worksheet ws in Globals.ThisWorkbook.Sheets)
            {
                if (ws.Name.Equals("run",StringComparison.OrdinalIgnoreCase))
                {
                    wsRun = ws;
                    hasRun = true;
                    break;
                }
            }
            if (!hasRun)
                MessageBox.Show("YOU NEED A SHEET NAMED \"run\" FOR THIS TO WORK CORRECTLY!\n" +
                    "PLEASE NAME THE INTENDED SHEET AS \"run\", THEN SAVE/CLOSE/REOPEN FILE.");
            else
                wsRun.Activate();
        }

        #region VSTO Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InternalStartup()
        {
            this.Startup += new System.EventHandler(ThisWorkbook_Startup);
            this.Shutdown += new System.EventHandler(ThisWorkbook_Shutdown);
        }

        #endregion

    }
}
