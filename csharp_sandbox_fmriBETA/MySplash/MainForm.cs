using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Threading;

namespace MySplash
{
    public partial class MainForm : Form
    {
        SplashScreenForm sf = new SplashScreenForm();

        public MainForm()
        {
            this.Hide();
            Thread splashthread = new Thread(new ThreadStart(SplashScreen.ShowSplashScreen));
            splashthread.IsBackground = true;
            splashthread.Start();
            InitializeComponent();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            SplashScreen.UdpateStatusText("Loading Items!!!");
            Thread.Sleep(1000);
            SplashScreen.UdpateStatusTextWithStatus("Success Message", TypeOfMessage.Success);
            Thread.Sleep(1000);
            SplashScreen.UdpateStatusTextWithStatus("Warning Message", TypeOfMessage.Warning);

            Thread.Sleep(1000);
            SplashScreen.UdpateStatusTextWithStatus("Error Message", TypeOfMessage.Error);
            Thread.Sleep(1000);
            SplashScreen.UdpateStatusText("Testing Default Message Color");
            Thread.Sleep(1000);
            SplashScreen.UdpateStatusText("Items Loaded..");
            Thread.Sleep(500);

            this.Show();
            SplashScreen.CloseSplashScreen();
            this.Activate();
        }
    }
}
